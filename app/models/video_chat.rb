class VideoChat < ApplicationRecord
  include Chat
  include ScheduledChatsHelper

  validates :name, presence: true, if: :external?
  validates :name, uniqueness: true, if: :external?
  validates :timings, presence: true
  validates :time_zone, presence: true
  validates :from_id, presence: true
  validates :business_id, presence: true
  validate :receiver_or_email

  belongs_to :sender, class_name: "User", foreign_key: "from_id"
  belongs_to :business, class_name: "User", foreign_key: "business_id"
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  belongs_to :receiver, class_name: "User", foreign_key: "to_id", optional: true

  has_one :review
  has_many :reviews
  has_one :chat_timesheet, as: :chat

  scope :upcoming, -> { where("timings > ? ", Time.current) }
  scope :upcoming_avail, -> { where("timings > ? AND is_call_ended = ?", Time.current-1.hour, false ) }
  scope :completed, -> { where("timings < ? ", Time.current) }
  scope :in_order, -> { order("timings desc") }
  scope :out_order, -> { order("timings asc") }

  after_create  :inhouse_push_notification
  before_save :downcase_fields
  FAKE_BOOKING_TIME = 3600

  def set_timings_time_in_zone(date:, tz:)
    Time.use_zone(tz) do
      self.timings = Time.zone.strptime(date, "%m-%d-%Y %H:%M %P")
    end
  end

  def download_name
    business_time.strftime("%m_%d_%Y %l-%M %p %Z VideoChatAPro")
  end

  def watermark
    business_id.present? && business.picture.present? ? business.picture.url(:small_thumb) : "watermark.png"
  end

  def minutes_available?
    business.minutes_available?
  end

  def receiver_or_email
    if email.blank? && to_id.blank?
      errors.add(:receiver, "missing. Please enter an email address or select an employee.")
    end
  end

  def phone_receivers
    receivers = phone_number.split(/[,;]/)
    receivers << receiver&.phone_number
    receivers << sender&.phone_number
    receivers.select(&:present?).uniq
  end

  def email_receivers
    receivers = email.split(/[,;]/)
    receivers << receiver&.email
    receivers << sender&.email
    receivers.select(&:present?).uniq
  end

  def email_receivers_without_sender
    receivers = email.split(/[,;]/)
    receivers << receiver&.email
    receivers.select(&:present?).uniq
  end

  def to_param
    session_id
  end

  def external?
    is_internal == "false"
  end

  def payments_made?
    false
  end

  def pro_name
    sender&.name || ""
  end

  def client_name
    receiver&.name || email_receivers.first || phone_receivers.first
  end

  def recipient_time
    timings.in_time_zone(time_zone)
  end

  def chat_time
    recipient_time
  end

  def form_time(default_time_zone)
    tz = time_zone || default_time_zone
    timings.in_time_zone(tz)
  end

  def early_link?(current_time = Time.current)
    current_time < recipient_time
  end

  def expired_link?(current_time = Time.current)
    current_time > recipient_time.advance(seconds: FAKE_BOOKING_TIME) || is_call_ended == true
  end

  def business_time
    recipient_time.in_time_zone(business.time_zone)
  end

  def when_to_run(minutes_before_video_chat = 5)
    timings.advance(minutes: -minutes_before_video_chat)
  end

  def schedule_reminder
    SmsService.send_reminder_sms_from_business(self)
  end
  handle_asynchronously :schedule_reminder, run_at: proc { |i| i.when_to_run }

  def schedule_notification
    PushNotification.send_notification(self)
  end
  handle_asynchronously :schedule_notification, run_at: proc { |i| i.when_to_run }


  def video_chat_completed
    begin
      if self.chat_timesheet
        unless is_call_ended
          timeslot = chat_timesheet&.chat_timeslots&.last
          timeslot.set_end(Time.current) if timeslot.present? && timeslot.end_time.nil?

          t_used = self.chat_timesheet&.chat_timeslots&.pluck(:time_used)&.sum
          self.update( is_call_ended: true, time_used: t_used )
          self.chat_timesheet.set_end( chat_timesheet.start_time + t_used.seconds )

          error = ""

          if connection_id.present?
            opentok = OpenTok::OpenTok.new(
                                ENV['opentok_api_key'],
                                ENV['opentok_api_secret'],
                                :timeout_length => 300
                              )
            opentok.connections.forceDisconnect(self.init_session_id, connection_id ) rescue "" #stream Destroyed
          end

         
        end
      end
   
    end
    
  end

   def when_to_run_video_chat_delay_job
    recipient_time.advance(seconds: FAKE_BOOKING_TIME)
  end

  def video_chat_delay
    self.video_chat_completed
   
  end
  handle_asynchronously :video_chat_delay, run_at: proc { |i| i.when_to_run_video_chat_delay_job }


  def end_call(seconds, end_time=nil, connection_id=nil)
    s_left = nil
    t_used = time_used
    VideoChat.transaction do
      chat_timesheet.chat_timeslots.last.set_end(end_time)
      seconds_to_count = seconds.to_i
      # update chat time used
      t_used = VideoChat.connection.execute(<<~SQL)
        update video_chats
          set time_used = #{seconds}
          where id = #{id}
        returning time_used
      SQL
     
    end

    self.time_used = t_used
   
    reload

    ""
  end
 def end_chat_when_to_run
   recipient_time.advance(seconds: FAKE_BOOKING_TIME)
 end

  def end_booked_chat
    self.reload
    sleep 1
    unless is_call_ended?
      end_time = Delayed::Job.find(self.finish_chat_delayjob_id).run_at
      seconds = (end_time.to_f - self.chat_timesheet.start_time.to_f ).to_i
      booked_seconds = FAKE_BOOKING_TIME

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

  def create_delay_job_end_call()
    
   
      # Delete last delayjob of end chat on complete time
      Delayed::Job.find_by(id: finish_chat_delayjob_id)&.destroy
      # create new delay job after extend time

      delay_job = self.video_chat_delay
      self.update(finish_chat_delayjob_id: delay_job.id)
    end

  def on_StartClock_delayJob(timesheet)
    if timesheet.client_start.present? && timesheet.pro_start.present?
      Delayed::Job.find(self.finish_chat_delayjob_id).destroy if self.finish_chat_delayjob_id.present?
      delay_job = self.video_chat_delay    #create New Delay Job for end call on time
      self.update(finish_chat_delayjob_id: delay_job.id)
    end
  end

  def review_for_id
    user_id
  end

  def inhouse_push_notification
    current_user = User.find(self.from_id)
    employee = self.to_id ? self.name : self.email

    message = "You scheduled a video chat with #{employee} at #{self.timings.strftime('%H:%M %p %Z - %A')}"

    Notification.create(title: "Video chat scheduled", message: message, from_id: self.to_id, to_id: current_user.id, videochat_id: self.id, chat_time: self.timings)
    fcm_push_notification(
      current_user.fcm_token, "In House video chat scheduled", message, nil, true, 'user'
    ) if current_user.fcm_token.present?

    if self.to_id.present?
      to = User.find(self.to_id)

      message = "Hello #{to.name}, #{current_user.name} has scheduled a video chat with you at #{self.timings.strftime('%H:%M %p %Z - %A')}."

      Notification.create(title: "Video chat scheduled", message: message, from_id: current_user.id, to_id: to.id, videochat_id: self.id, chat_time: self.timings)
      fcm_push_notification(
        to.fcm_token, "In House video chat scheduled", message, nil, true, 'user'
      ) if to.fcm_token.present?
    end
  rescue Exception => e
    render json: { error: e.message, status: 401 }
  end

  def downcase_fields
    self.email.downcase!
  end

  def expected_end_time
    recipient_time.advance(seconds: FAKE_BOOKING_TIME)
  end

  def total_captured_time
    FAKE_BOOKING_TIME
  end

end
