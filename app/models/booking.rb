class Booking < ApplicationRecord
  include Chat
  include ScheduledChatsHelper

  belongs_to :user, optional: true
  belongs_to :client, optional: true
  has_many :payment_transactions, dependent: :destroy
  has_one :review
  has_many :reviews
  has_one :chat_timesheet, as: :chat, dependent: :destroy

  validates :user_id,
    :booking_date,
    :booking_time,
    :agree_with_terms_and_conditions,
    :time_zone,
    :city,
    :state,
    :issue,
    presence: true

  geocoded_by :address do |object, results|
    if results.present?
      object.city = results.first.city
      object.state = results.first.state
      object.latitude = results.first.latitude
      object.longitude = results.first.longitude
    end
  end
  after_validation :geocode, if: ->(obj) { obj.new_record? || obj.city_changed? || obj.state_changed? }

  before_create :set_slug
  CALL_DURATIONS = [["15 minutes",900],["30 minutes",1800],["45 minutes",2700],["60 minutes",3600]]
  scope :completed, -> { joins(:payment_transactions) }
  scope :booking_completed, -> { includes(:payment_transactions).where(payment_transactions: {transaction_status: "paid"}) }
  #TODO need to modify the query in better way for incomplete scope
  scope :in_completed, -> { old_in_completed.or(new_in_completed) }
  scope :old_in_completed, -> { includes(:payment_transactions).where(payment_transactions: {id: nil}) }
  scope :new_in_completed, -> { includes(:payment_transactions).where(payment_transactions: {transaction_status: "captured"})}
  scope :in_order, -> { order(booking_date: :desc, booking_time: :desc) }

  scope :upcoming, -> { includes(:payment_transactions).where("booking_time > ? AND is_call_ended = ?", Time.current - 1.hour, false ) }

  after_create  :push_notification
  FAKE_BOOKING_TIME = 3600
  def self.any_availability_error?(start_time, call_minutes, user_id)
    max_limit = start_time+(call_minutes - 15).minutes
    booking_user = User.find(user_id)
    next_immidiate_booking_time = booking_user.bookings
      .where(
        "booking_time >= ? AND booking_time <= ? ",
        start_time,
        max_limit
      ).map(&:booking_time).min

    error_message = ""

    if next_immidiate_booking_time
      minutes_available = (next_immidiate_booking_time - start_time)/60
      minutes_availble_message = minutes_available > 0 ? "Max availble time is #{minutes_available.to_i} minutes.": ""
      error_message =
        "The pro is already booked for the time frame you are trying to book. #{minutes_availble_message}"
    end

    error_message
  end

  def address
    [city, state].compact.join(', ')
  end

  def set_slug
    loop do
      self.slug = SecureRandom.uuid
      break unless self.class.where(slug: slug).exists?
    end
  end

  def download_name
    user_time.strftime("%m_%d_%Y %l-%M %p %Z VideoChatAPro")
  end

  def watermark
    user.business? && user.picture.present? ? user.picture.url(:small_thumb) : "watermark.png"
  end

  def to_param
    slug
  end

  def charged_amount
    payment_transactions.pluck(:amount).compact.sum
  end

  def customer_share
    payment_transactions.pluck(:customer_amount).compact.sum
  end

  def set_booking_time_in_zone(date:, tod:)
    Time.use_zone(time_zone) do
      self.booking_time = Time.zone.parse("#{date} #{tod}")
    end
  end

  def client_time
    booking_time.in_time_zone(time_zone)
  end

  def chat_time
    client_time
  end

  def user_time
    booking_time.in_time_zone(user.time_zone)
  end

  def booking_minutes
    payment_transactions.pluck(:call_time_booked).sum/60
  end

  def admin_time
    booking_time.in_time_zone(AdminUser.default_time_zone)
  end

  def when_to_run(minutes_before_video_chat = 5)
    booking_time.advance(minutes: -minutes_before_video_chat)
  end

  def send_sms_reminders
    if user.phone_number.present?
      SmsService.send_reminder_sms_to_user(self)
      sleep 1 if Rails.env.production? || Rails.env.staging? # don't rate limit tests
    end

    if client.phone_number.present?
      SmsService.send_reminder_sms_to_client(self)
    end
  end
  handle_asynchronously :send_sms_reminders, run_at: proc { |i| i.send(:when_to_run) }

  def booking_schedule_notification
    PushNotification.booking_notification(self)
  end
  handle_asynchronously :booking_schedule_notification, run_at: proc { |i| i.when_to_run }

   def end_chat_when_to_run
 
    if is_booking_fake
        booking_time.advance(seconds: FAKE_BOOKING_TIME)
      else
        booking_time.advance(seconds: total_captured_time)
    end
  end

  def end_booked_chat
    self.reload
    sleep 1
    unless is_call_ended?
      end_time = Delayed::Job.find(self.finish_chat_delayjob_id).run_at
      seconds = (end_time.to_f - self.chat_timesheet.start_time.to_f ).to_i
      booked_seconds = chat.is_a?(Booking) && !chat.is_booking_fake? ? payment_transactions.pluck(:call_time_booked).compact.sum : FAKE_BOOKING_TIME

      if (seconds < booked_seconds)
        delay_job = self.end_booked_chat
        self.update(finish_chat_delayjob_id: delay_job.id)
      else
        self.end_call(seconds, end_time, connection_id)
      end
    end
    Rails.logger.info "------------- Call End from Delay JOB ------------- "
  rescue => e
    Rails.logger.warn "Exception occured while running delayed job for autocut"
    Rails.logger.warn "Chat ID: #{id}"
    Rails.logger.warn "Error: #{e.message}"
    Rails.logger.warn "Error backtrace: #{e.backtrace}"
  end
  handle_asynchronously :end_booked_chat, run_at: proc { |i| i.end_chat_when_to_run }

  def when_to_run_refund_payment
    if is_booking_fake
      booking_time.advance(seconds: FAKE_BOOKING_TIME)
    else
      booking_time.advance(seconds: total_captured_time)
    end
  end

  def booking_refund_payment
    self.booking_chat_completed
    if !is_booking_fake && !is_call_ended
      self.payment_transactions.each do |pt|
        @response = Stripe::Refund.create({charge: pt.charge_id})
        pt.amount_refund = (@response.amount.to_f)/100.0
        pt.transaction_status = @response.object
        pt.save
        Rails.logger.info "******************************************************************************"
        Rails.logger.info "Refund booked amount - #{pt.amount_refund.to_f} to client #{self.client.email}"
      end
      BookingMailer.send_email_to_admin_refund_payment(self).deliver_now
      BookingMailer.send_email_to_client_refund_payment(self).deliver_now
    end
  rescue => e
    Rails.logger.info "Error on refund booked amount - #{e.inspect}"
  end
  handle_asynchronously :booking_refund_payment, run_at: proc { |i| i.when_to_run_refund_payment }

  def booking_chat_completed
    begin
      if self.chat_timesheet
        unless is_call_ended
          timeslot = chat_timesheet&.chat_timeslots&.last
          timeslot.set_end(Time.current) if timeslot.present? && timeslot.end_time.nil?

          t_used = self.chat_timesheet&.chat_timeslots&.pluck(:time_used)&.sum
          self.update( is_call_ended: true, time_used: t_used )
          self.chat_timesheet.set_end( self.chat_timesheet.start_time + t_used.seconds )

          error = ""

          if connection_id.present?
            opentok = OpenTok::OpenTok.new(
                                ENV['opentok_api_key'],
                                ENV['opentok_api_secret'],
                                :timeout_length => 300
                              )
            opentok.connections.forceDisconnect(self.init_session_id, connection_id ) rescue "" #stream Destroyed
          end

          error = stripe_payment(t_used, connection_id, error)
          error = send_email_notification(error)
        end
      end
    rescue => e
      Rails.logger.info "Error on Complete booking chat - #{e.inspect}"
      error = "Stripe: #{e.message}"
      Rails.logger.info "Error ---> #{error}"
      GenericMailer.send_stripe_payment_error(self, error).deliver_now if error.present?
    end
  end

  def early_link?(current_time = Time.current)
    current_time < booking_time
  end

  def expired_link?(current_time = Time.current)
    if is_booking_fake
      current_time > booking_time.advance(seconds: FAKE_BOOKING_TIME)
    else
      current_time > booking_time.advance(seconds: total_captured_time)
    end
  end

  def total_captured_time
    if is_booking_fake
      FAKE_BOOKING_TIME
    else
      payment_transactions.pluck(:call_time_booked).compact.sum
    end
  end

  def expected_end_time
    if is_booking_fake?
      booking_time.advance(seconds: FAKE_BOOKING_TIME)
    else
      booking_time.advance(seconds: total_captured_time)
    end
  end


  def valid_link?
    !early_link? && !expired_link?
  end

  def minutes_available?
    true
  end

  def payments_made?
    payment_transactions.where(transaction_status: "paid").size > 0
  end

  def pro_name
    user.name
  end

  def client_name
    client.full_name
  end

  def end_call(seconds, end_time, connection_id=nil)
    begin
      t_used = 0
      Booking.transaction do
       
          chat_timesheet.chat_timeslots.last.set_end(end_time)
          # update chat time used
          t_used = Booking.connection.execute(<<~SQL).to_a.first["time_used"]
            update bookings
              set time_used = #{seconds}
              where id = #{id}
            returning time_used
          SQL
        # end

      end
      reload
      error = ""

      if connection_id.present?
        opentok = OpenTok::OpenTok.new(
                            ENV['opentok_api_key'],
                            ENV['opentok_api_secret'],
                            :timeout_length => 300
                          )
        opentok.connections.forceDisconnect(self.init_session_id, connection_id ) rescue "" #stream Destroyed
      end

      # if is_booking_fake
        # error = stripe_payment(t_used, connection_id, error)
        # error = send_email_notification(error)
      # end
    rescue Exception => e
      Rails.logger.warn "Booking -> #{self.inspect}"
      Rails.logger.warn "Handle Error -> #{e.inspect} "
      error = "Stripe: #{e.message}"
    end
    GenericMailer.send_stripe_payment_error(self, error).deliver_now if error.present?
    error
  end

  def stripe_payment(t_used, connection_id, error)

    processor = StripeProcessor.new(self, t_used)
    if processor.process
      Rails.logger.info "Stripe Payment Success -> #{processor.inspect} "
      if connection_id.present?
        opentok = OpenTok::OpenTok.new(
                            ENV['opentok_api_key'],
                            ENV['opentok_api_secret'],
                            :timeout_length => 300
                          )
        opentok.connections.forceDisconnect(self.init_session_id, connection_id ) rescue "" #stream Destroyed
      end
    else
      error = "Unable to contact Stripe. Please contact support."
    end
    error
  end

  def send_email_notification(error)
    if self.user.pro? || self.user.business?
      Notification.create(
        title: "Video Chat Summary",
        message: "Click for video chat summary details",
        booking_id: self.id,
        to_id: self.user_id,
        of_type: "end_call"
      )
    end
    BookingMailer.send_summary_to_user(self).deliver_later
    BookingMailer.send_summary_to_client(self).deliver_later

    Rails.logger.info "Booking -> #{self.inspect}"
    Rails.logger.info "Chat TimeSheet -> #{self.chat_timesheet.inspect}"
    Rails.logger.info "Payment Transactions -> #{self.payment_transactions.map{|pt| pt.inspect } }"
    Rails.logger.info "Chat TimeSlots Details -> #{self.chat_timesheet.chat_timeslots.map{|cts| cts.inspect } }" if self.chat_timesheet.chat_timeslots.present?
    error
  rescue => e
    e.message
  end

  def review_for_id
    user_id
  end

  def push_notification
    user = self.user
       message = "Hello #{user.name} you have a new customer . #{self.client} has scheduled to video chat with you at #{self.booking_time.strftime('%H:%M %p %Z')} [#{ self.day_or_date }]."
       title = "Video chat scheduled"
       Notification.create(
           title: title, message: message,
           from_id: self.client_id, to_id: user.id,
           booking_id: self.id, chat_time: self.booking_time
         )
       fcm_push_notification(
           user.fcm_token, title, message, nil, true, 'user'
         ) if user.fcm_token.present?
       client = self.client
       message_client = "Hello #{client}  your videochat is scheduled at #{self.booking_time.strftime('%H:%M %p %Z')} [#{ self.day_or_date }]."  
       Notification.create(
         title: title, message: message_client,
         from_id: user.id, to_id: self.client_id,
         booking_id: self.id, chat_time: self.booking_time
       ) 
      client_token=Client.where(email: client.email).pluck(:fcm_token).flatten.uniq
       fcm_push_notification(
        client_token, title, message_client, nil, true, 'client'
       ) # if client.fcm_token.present?
  end

  def create_charge(call_time, charge = nil)
    unless is_booking_fake

      if self.client.customer_id.blank?
        render json: { message: "Client card not added" } and return false
      end
      amount = (total_donation(call_time.to_i) * 100).ceil
      unless charge
        charge = Stripe::Charge.create({
                                         amount: amount,
                                         currency: 'usd',
                                         description: 'Extend Call charge',
                                         customer: self.client.customer_id,
                                         capture: false,
                                         transfer_data: { amount: (amount * ( self.percentage_got_by_user )).to_i,
                                            destination: self.user.stripe_custom_account_id }
                                       })
      end
      @transaction = PaymentTransaction.new
      @transaction.booking_id = self.id
      @transaction.charge_id = charge.id
      @transaction.amount_captured = charge.amount
      @transaction.transaction_status = "captured"
      @transaction.call_time_booked = call_time.to_i
      @transaction.save
    end

    # unless is_booking_fake
      # Delete last delayjob of end chat on complete time
      Delayed::Job.find_by(id: finish_chat_delayjob_id)&.destroy
      # create new delay job after extend time

      delay_job = self.booking_refund_payment
      self.update(finish_chat_delayjob_id: delay_job.id)
    # end


    true
  rescue => e
    error_message = e.message
    render json: { error: error_message }, status: 400 and return false
  end

  def percentage_got_by_user
    app_setting = AppSetting.last
    business_commission = app_setting.business_commission.to_f/100
    pro_commission = app_setting.pro_commission.to_f/100

    self.user.business? ? business_commission : pro_commission
  end

  def total_donation(time)
    amount_per_minute = self.rate_per_minute
    amount_per_second = amount_per_minute.to_f / 60
    (amount_per_second * time)
  end

  def on_StartClock_delayJob(timesheet)
    if timesheet.client_start.present? && timesheet.pro_start.present?
      Delayed::Job.find(self.finish_chat_delayjob_id).destroy if self.finish_chat_delayjob_id.present?
      delay_job = self.booking_refund_payment    #create New Delay Job for end call on time
      self.update(finish_chat_delayjob_id: delay_job.id)
    end
  end

  def day_or_date
    bookingDate = self.booking_date.in_time_zone(self.time_zone).to_date
    return "Today" if bookingDate.today?
    return "Tomorrow" if bookingDate == Date.tomorrow
    bookingDate.strftime('%m/%d/%y')
  end

  def rate_per_minute
    amount.present? ? (amount.to_f / 15).to_f.ceil(2) : 0
  end

  def chat_available
    booking_time > Time.current - total_captured_time.seconds
  end
end
