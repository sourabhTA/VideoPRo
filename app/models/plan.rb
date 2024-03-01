class Plan < ApplicationRecord
  has_many :users
  has_many :features, dependent: :destroy
  accepts_nested_attributes_for :features, :allow_destroy => true

  validates :name, :display_price, presence: true
  validates :minutes_allowed, presence: true
  validates :name, uniqueness: true

  scope :not_free, -> { where("display_price != 0.0") }
  scope :not_free_pro, -> { where("name != 'Free Pro Profile' AND name != 'Featured Pro Profile'") }
  scope :free, -> { where(display_price: 0.0) }
  scope :free_pro, -> { where("name = 'Free Pro Profile' OR name = 'Featured Pro Profile'") }
  scope :free_business, -> { where(name: "Free Business Listing") }
  scope :active, -> { where(is_active: true) }
  scope :in_order, -> { order(display_price: :asc) }

  def to_s
    name
  end

  def save_on_stripe
    if valid?
      begin
        plan = Stripe::Plan.create(:amount => (display_price * 100).to_i,
                                   :interval => 'month',
                                   :product => {
                                       :name => name
                                   },
                                   :active => is_active,
                                   :currency => 'usd')

        self.stripe_id = plan.id
        save(validate: false)
      rescue => e
        errors.add :plan, e.message
        false
      end
    else
      false
    end
  end

  # https://stripe.com/docs/api#update_plan
  # By design, you cannot change a plan’s ID, amount, currency, or billing cycle.
  def update_on_stripe(params)
    if valid?
      begin
        stripe_plan = Stripe::Plan.retrieve(stripe_id)
        puts stripe_plan.inspect
        stripe_plan.active = ActiveModel::Type::Boolean.new.cast(params[:is_active])
        stripe_plan.save
        update(params)
      rescue => e
        errors.add :plan, e.message
        false
      end
    else
      false
    end
  end

  def delete_on_stripe
    begin
      stripe_plan = Stripe::Plan.retrieve(stripe_id)
      stripe_plan.delete
      destroy
    rescue => e
      errors.add :plan, e.message
      false
    end
  end

  def add_bank_account
    customer = Stripe::Customer.retrieve(stripe_customer_id)
    customer.sources.create({:source => {:object => "bank_account", :account_number => bank_account_number,  :country => country,  :currency => "USD", :account_holder_name => account_holder_name, :account_holder_type => account_holder_type, :routing_number => routing_number }})
  end
end
