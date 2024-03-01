class User < ApplicationRecord
  # Include default devise modules. , :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  after_create :send_confirmation_email, if: -> { !Rails.env.test? && User.devise_modules.include?(:confirmable) && !self.is_imported }
  after_create :set_free_plan, if: -> { self.business? }
  after_commit :set_featured, if: -> { self.pro? && self.saved_change_to_plan_id? }

  acts_as_paranoid
  extend FriendlyId
  friendly_id :name_with_trade, use: :slugged

  alias_attribute :scraped_link, :scrapped_link

  def self.rate_per_minute(rate)
    ActionController::Base.helpers.number_to_currency((rate.to_f / 15.to_f).ceil(2))
  end

  RATES = [[rate_per_minute(25), "25"], [rate_per_minute(35), "35"], [rate_per_minute(45), "45"], [rate_per_minute(55), "55"]]
  SORT_OPTIONS = [["Highest rated", "highest_rated"], ["Highest to lowest price", "highest_to_lowest_price"],
    ["Lowest to highest price", "lowest_to_highest_price"]]

  PACIFIC = "Pacific Time (US & Canada)"
  MOUNTAIN = "Mountain Time (US & Canada)"
  CENTRAL = "Central Time (US & Canada)"
  EASTERN = "Eastern Time (US & Canada)"

  TIME_ZONES = [
    PACIFIC,
    MOUNTAIN,
    CENTRAL,
    EASTERN
  ]

  SUBSCRIBED_AND_PAID_CONDITIONS = <<~SQL.squish
    stripe_customer_id is not null
    and subscribed_at is not null
    and subscription_expires_at is not null
    and plan_id is not null
    and stripe_subscription_id is not null
    and stripe_payment_id is not null
    and free_of_charge is false
    and seconds_left > 0
  SQL

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  paginates_per 10
  self.per_page = 10
  # devise :database_authenticatable, :registerable, :confirmable,
  #   :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :picture, PictureUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  belongs_to :plan, optional: true
  belongs_to :category, optional: true
  has_many :stripe_events
  has_many :bank_accounts
  has_many :bookings
  has_many :claims
  has_many :video_chats
  has_many :license_informations, inverse_of: :user
  has_many :categories, through: :license_informations
  accepts_nested_attributes_for :license_informations, reject_if: :all_blank, allow_destroy: true
  has_many :business_addresses, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :business_addresses, reject_if: :all_blank, allow_destroy: true
  has_many :business_pictures, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :business_pictures, reject_if: :all_blank, allow_destroy: true
  has_many :business_videos, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :business_videos, reject_if: :all_blank, allow_destroy: true
  has_many :reviews, dependent: :destroy
  belongs_to :business, class_name: "User", foreign_key: "business_id", optional: true
  has_many :scheduled_services
  has_many :user_emails, as: :emailable
  has_many :notification_recipients, dependent: :destroy

  has_secure_token
  geocoded_by :address do |object, results|
    if results.present?
      object.street = results.first.route
      object.city = results.first.city
      object.state = results.first.state
      object.country = results.first.country
      object.zip = results.first.postal_code
      object.latitude = results.first.latitude
      object.longitude = results.first.longitude
    end
  end
  after_validation :geocode, if: ->(obj) { obj.new_record? || obj.address_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed? }
  before_validation :ensure_token

  enum role: {pro: 0, business: 1, employee: 2}

  #scope :with_time_zone, ->(zones) { where("time_zone in (?)", zones) } 
  scope :with_slugs, -> { where.not(slug: nil) }
  scope :with_names, -> { where.not(name: nil) }
  scope :pros, -> { where(role: "pro") }
  scope :employees, ->(business_id) { where(role: "employee", business_id: business_id) }
  scope :notification_allowed, -> { where(all_notifications: true) }
  scope :business_staff, ->(business_id, current_user_id) { where(role: "business").where("slug is not null").or(where(role: "employee")).where("business_id = ? AND id != ?", business_id, current_user_id) }
  scope :businesses, -> { with_slugs.where(role: "business") }
  scope :all_business_staff, ->(business_id) { where(role: "business").where("slug is not null").or(where(role: "employee")).where("business_id = ?", business_id) }
  scope :all_employees, -> { where(role: "employee") }
  scope :all_businesses, -> { businesses.imported_notconfirmed }
  # scope :imported_businesses, -> { where("scrapped_link IS NOT NULL").where(role: "business").where("slug is not null") }
  scope :imported_businesses, -> { where(role: "business", is_imported: true).no_confirmation }
  scope :imported_confirmed, -> { where(role: "business", is_imported: true).where.not(confirmed_at: nil) }
  scope :archived_users, -> { only_deleted }
  scope :in_complete, -> { where("profile_completed = ? AND reminder_count <= ?", false, 2) }
  scope :visible, -> { where(is_hidden: false) }
  scope :hidden, -> { where(is_hidden: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :trades, ->(category_id) { joins(:license_informations).where("license_informations.category_id = ?", category_id) }
  scope :with_account, -> { joins(:bank_accounts).group("users.id").having("count(bank_accounts) > 0") }
  scope :city_or_zip, ->(city_or_zip) { where("city = ? OR zip = ?", city_or_zip, city_or_zip) }
  scope :user_types, ->(help_with) { where("role = ?", roles[help_with.to_sym]) }
  scope :subscribed_and_paid, -> { where(SUBSCRIBED_AND_PAID_CONDITIONS) }
  scope :order_less, ->(users_array) { where("id NOT IN (?)", users_array.map(&:to_i)).order(Arel.sql("RANDOM()")) }
  scope :in_order, -> { order(Arel.sql("RANDOM()")) }
  scope :seems_duplicate, ->{ duplicate_users }

  # Search scopes
  scope :created_desc, -> { order(created_at: :desc) }
  scope :featured_desc, -> { ((order(is_featured: :desc).order("picture DESC NULLS LAST"))or(order(is_verified: :desc))) }
  scope :highest_rated, -> { select("users.*, AVG(reviews.rating) as avg_rating").left_joins(:reviews).group("users.id").order("avg_rating desc NULLS LAST") }
  scope :highest_to_lowest_price, -> {
    order(rate: :desc)
      .order(is_featured: :desc)
      .order(:id)
  }
  scope :lowest_to_highest_price, -> {
    order(rate: :asc)
      .order(is_featured: :desc)
      .order(:id)
  }

  scope :email_subscribed, -> { where(email_subscription: true) }
  scope :live, -> { where(stripe_customer_id: nil) }
  scope :verified, -> { where(is_verified: true) }
  scope :no_confirmation, -> { where(confirmed_at: nil) }
  scope :imported_notconfirmed, -> { where("is_imported IS false OR (is_imported IS true AND confirmed_at IS NOT NULL)",false,true) }
  scope :no_stripe, -> { where(stripe_customer_id: nil) }
  scope :no_plan, -> { where(subscribed_at: nil, subscription_expires_at: nil) }
  scope :active_plan, -> { where("subscribed_at IS NOT NULL AND subscription_expires_at IS NOT NULL AND subscription_expires_at <= ?", DateTime.now.end_of_day) }
  scope :have_tokens, -> { where("length(token) > 0") }
  scope :all_segments, -> { where("") }
  scope :scrapped, -> { where("scrapped_link IS NOT NULL") }
  scope :not_scraped, -> { where(scrapped_link: nil) }

  # create index on users (role) where (name is not null and not is_hidden and slug is not null and scrapped_link is null);
  scope :base_search, -> {
    with_names
      .visible
      .with_slugs
      .not_scraped
  }

  after_create :notify_admin
  after_create :business_setup
  after_update :crop_picture
  validates :facebook_url, url: {allow_nil: true, allow_blank: true}
  validates :google_my_business, url: {allow_nil: true, allow_blank: true}
  validates :twitter_url, url: {allow_nil: true, allow_blank: true}
  validates :instagram_url, url: {allow_nil: true, allow_blank: true}
  validates :youtube_url, url: {allow_nil: true, allow_blank: true}
  validates :linkedin_url, url: {allow_nil: true, allow_blank: true}

  [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each do |dow|
    serialize :"#{dow}_break_start_time", Tod::TimeOfDay
    serialize :"#{dow}_end_time", Tod::TimeOfDay
    serialize :"#{dow}_break_end_time", Tod::TimeOfDay
    serialize :"#{dow}_start_time", Tod::TimeOfDay
  end

  def self.duplicate_users
    names = User.all.map(&:name).reject(&:blank?).map(&:downcase)
    name_array = names.select{|element| names.count(element.downcase) > 1 }.uniq
    User.where("name ILIKE ANY ( array[?] )", name_array)
  end

  def employees
    User.where(role: "employee", business_id: id) if business?
  end

  def self.duplicate_users
    names=User.all.map(&:name).reject(&:blank?).map(&:downcase)
    name_array = names.select{|element| names.count(element.downcase) > 1 }.uniq
    User.where("name ILIKE ANY ( array[?] )", name_array)
  end

  def first_name
    name.to_s.split(' ').first
  end

  def scrapped?
    !scrapped_link.blank?
  end

  def crop_picture
    picture.recreate_versions! if crop_x.present?
  end

  def name_with_trade
    "#{license_informations.try(:first).try(:category).try(:name)}-#{name}"
  end

  def is_paid_business?
    !stripe_customer_id.blank? && !subscribed_at.blank? && !subscription_expires_at.blank? &&
      !plan_id.blank? && !stripe_subscription_id.blank? && !stripe_payment_id.blank?
  end

  def should_generate_new_friendly_id?
    name_changed? || license_informations.try(:first).try(:category_id_changed?)
  end

  validates :agree_to_terms_and_service, presence: true, on: :create

  validates :business_website, url: {allow_nil: true}, if: ->(user){ user.business_website.present? }
  validates_format_of :business_website, without: /videochatapro\.com/i, message: "must not of domain videochatapro.com"

  # validates :phone_number, phone: {possible: true, types: [:mobile], countries: [:us]}, on: :update

  def to_s
    name.to_s
  end

  def staff_name
    "#{name} (#{role})"
  end

  def to_param
    slug
  end

  def rate_per_minute
    rate.present? ? (rate.to_f / 15).to_f.ceil(2) : 0
  end

  def notify_admin
    GenericMailer.user_created(self).deliver
  end

  def business_setup
    update_column(:business_id, id) if business?
  end

  def setup_stripe_custom_account
    if role == "business"
      self.account = if country.blank? || (country == "US")
        Stripe::Account.create({
          country: "US",
          type: "custom",
          requested_capabilities: ["platform_payments"]
        }).id
      else
        Stripe::Account.create({
          country: country,
          type: "custom",
          business_type: "individual",
          first_name: name,
          business_url: ""
        }).id
      end
      save!
    end
  end

  def custom_account_status
    unless self.stripe_custom_account_id.blank?
      stripe_account_id = self.stripe_custom_account_id
      stripe_account = Stripe::Account.retrieve(stripe_account_id)
      if stripe_account.charges_enabled == true
        self.update_attribute("stripe_account_status", "approved")
      else
        self.update_attribute("stripe_account_status", "pending")
      end
    end
    [self.stripe_account_status, stripe_account]
  end

  def minutes_available?
    plan = Plan.free.first
    if role == "business"
      seconds_left > 0 && plan_id != plan.id
    elsif role == "employee"
      business.seconds_left > 0 && business.plan_id != plan.id
    end
  end

  def minutes_left
    case role
    when "business"
      (seconds_left / 60).to_i
    when "employee"
      (business.seconds_left / 60).to_i
    else
      0
    end
  end

  def day_on?(day)
    dow = %w[monday tuesday wednesday thursday friday saturday sunday].detect { |d| d == day.downcase }
    dow ? public_send("is_#{dow}_on") : false
  end

  def tz
    Time.find_zone(time_zone)
  end

  def available?(current_time = Time.current)
    dow = current_time.strftime("%A").downcase
    return false unless day_on?(dow)

    start_time = public_send("#{dow}_start_time")&.on(current_time, tz)
    end_time = public_send("#{dow}_end_time")&.on(current_time, tz)

    return false if start_time.blank? || end_time.blank?

    current_time >= start_time && current_time <= end_time
  end

  def staff_role?(*roles)
    [roles].flatten.map(&:to_sym)
    roles.include? role.to_sym
  end

  def business_users
    User.business_staff(business_id, id)
  end

  def all_business_users
    User.all_business_staff(business_id)
  end

  def name_with_bio
    "<image src='#{picture.url(:mini_thumb)}' width='50px'></image>" "#{self} : <br/> BIO: #{description}"
  end

  def check_words_lengths
    # errors[:description] << "70 words are allowed" if description && description.split.size > 70
    errors[:specialties] << "40 words are allowed" if scrapped_link.nil? && specialties && specialties.split.size > 70
    errors[:product_knowledge] << "40 words are allowed" if scrapped_link.nil? && product_knowledge && product_knowledge.split.size > 40
  end

  def save_and_make_payment(plan, card_token)
    old_plan = self.plan
    # && stripe_subscription_id.nil?
    if stripe_customer_id.nil?
      create_stripe_customer_and_subscription(plan, card_token)
    else
      update_subscription_and_create_invoice(plan, old_plan)
    end
  end

  def update_subscription_and_create_invoice(plan, old_plan)
    old_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
    old_subscription.cancel_at_period_end = false
    old_subscription.items = [{id: old_subscription.items.data[0].id, plan: plan.stripe_id}]
    new_subscription = old_subscription.save

    unless old_plan.id == Plan.free_business.first.id
      invoice = Stripe::Invoice.create({customer: stripe_customer_id})
      invoice = Stripe::Invoice.retrieve(invoice.id)
      invoice.pay
    end

    self.plan = plan
    self.stripe_subscription_id = new_subscription.id
    save!
  rescue => e
    errors.add :base, e.message
    false
  end

  def create_stripe_customer_and_subscription(plan, card_token)
    customer = if plan.stripe_id == BASIC_PLAN
      if is_van_paid?
        Stripe::Customer.create(
          source: card_token,
          plan: plan.stripe_id,
          email: email,
          coupon: EIGHTY_PERCENT_OFF
        )
      else
        Stripe::Customer.create(
          source: card_token,
          plan: plan.stripe_id,
          email: email,
          coupon: NINTY_PERCENT_OFF
        )
      end
    else
      Stripe::Customer.create(
        source: card_token,
        plan: plan.stripe_id,
        email: email
      )
    end

    if confirmed? && !claim_approved?
      self.claim_approved = true
    end

    self.stripe_customer_id = customer.id
    self.stripe_subscription_id = customer.subscriptions.data[0].id
    self.plan = plan

    save!
  rescue Stripe::CardError => e
    errors.add :base, e.message
    false
  end

  def update_customer_card_token(card_token)
    Stripe::Customer.update(stripe_customer_id, {source: card_token})
  rescue Stripe::CardError => e
    errors.add :base, e.message
    false
  end

  def last4
    return "" if stripe_customer_id.nil?
    begin
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      cards = customer.sources
      return "" if cards.blank?
      "Current Card Ending in #{cards.first.last4}"
    rescue => e
    end
  end

  def self.valid_login?(email, password)
    user = find_by(email: email)
    if user&.valid_password?(password)
      user
    end
  end

  def allow_token_to_be_used_only_once
    regenerate_token
    touch(:token_created_at)
  end

  def logout
    invalidate_token
  end

  def ensure_token
    self.token = generate_hex(:token) unless token.present?
  end

  def generate_hex(column)
    loop do
      hex = SecureRandom.hex(10)
      break hex unless self.class.where(column => hex).any?
    end
  end

  def self.with_unexpired_token(token, period)
    where(token: token).where("token_created_at >= ?", period).first
  end

  def pending_stripe_validation?
    stripe_account_status == "pending"
  end

  def stripe_valid?
    !pending_stripe_validation?
  end

  class TimeSlot < Struct.new(:tod, :disabled)
    def self.sort(slots)
      slots.sort_by do |slot|
        slot.tod[-2, 2] + slot.tod.gsub("12:", "00:")
      end
    end
  end

  def time_slots_for(dow:, booking_date:, tz:, current_time: Time.current)
    return [] unless day_on?(dow)
    schedule_buffer = 15 # minutes
    current_time = current_time.advance(minutes: schedule_buffer)
    minutes = 15 * 60

    user_tz = Time.find_zone(time_zone)

    c_time = current_time.in_time_zone(user_tz).in_time_zone(tz)
    current_tod = Tod::TimeOfDay.new(c_time.hour, c_time.min)
    shift, break_time = shift_on(dow)

    available_slots = shift.range.step(minutes).to_a.map { |seconds|
      tod = Tod::TimeOfDay.new(0) + seconds
      next nil if break_time.include?(tod)
      TimeSlot.new(tod.on(booking_date, user_tz).in_time_zone(tz).strftime("%I:%M %p"), false)
    }.compact

    booked_slots = bookings.where(booking_date: booking_date).includes(:payment_transactions).map do |booking|
      slots_occupied = [booking.booking_time.in_time_zone(tz).strftime("%I:%M %p")]
      (booking.booking_minutes/15).times.each{|i| slots_occupied <<  (booking.booking_time+(15*i).minutes).in_time_zone(tz).strftime("%I:%M %p")}
      slots_occupied
    end

    booked_slots = booked_slots.flatten.uniq

    available_slots.each do |s|
      time_passed = c_time.to_date == booking_date && Tod::TimeOfDay.parse(s.tod) < current_tod
      s.disabled = time_passed || booked_slots.include?(s.tod)
    end

    TimeSlot.sort(available_slots)
  end

  def user_category
    license_informations.order(updated_at: :desc)&.first&.category&.name
  end

  private

  def shift_on(dow)
    exclusive = true

    schedule_start = public_send("#{dow}_start_time")
    schedule_end = public_send("#{dow}_end_time")

    if schedule_start.nil? || schedule_end.nil?
      # raise "Schedule start or end time is nil"
      # Or, return a default value:
      return [Tod::Shift.new(Tod::TimeOfDay.new(0, 0), Tod::TimeOfDay.new(0, 0), exclusive), Tod::Shift.new(Tod::TimeOfDay.new(0, 0), Tod::TimeOfDay.new(0, 0), exclusive)]
    end

    shift = Tod::Shift.new(schedule_start, schedule_end, exclusive)

    break_start = public_send("#{dow}_break_start_time")
    break_end = public_send("#{dow}_break_end_time")
    break_time = Tod::Shift.new(break_start, break_end, exclusive)

    [shift, break_time]
  end

  def invalidate_token
    update_columns(token: nil)
    touch(:token_created_at)
  end

  def send_confirmation_email
    self.send_confirmation_instructions
  end

  def set_free_plan
    if Plan.free_business.first
      self.update(plan_id: Plan.free_business.first.id)
    end
    Rails.logger.info "============== Set free plan to new user ==================#{self.inspect}"
  end

  def set_featured
    self.update(is_featured: self.plan.name == "Featured Pro Profile")
  end
end
