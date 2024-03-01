class SmsService
  include Rails.application.routes.url_helpers

  def self.send_sms_to_user(booking)
    new.send_sms_to_user(booking)
  end

  def send_sms_to_user(booking)
    body = send_sms_to_user_body(booking)
    receivers = booking.user.business? ? booking.user.all_business_users.notification_allowed.map(&:phone_number) : [booking.user.phone_number]
    receivers.each do |receiver|
      send_message(receiver, body) unless receiver.blank?
      sleep 1 if receivers.size > 1 && ( Rails.env.production? || Rails.env.staging? )
    end
  end

  def send_sms_to_user_body(booking)
    shortened = Shortener::ShortenedUrl.generate(chat_url(booking.professional_token))
    link = short_url(shortened)
    "Hello #{ booking.user }, You Have a New Customer! #{ booking.client } has scheduled to Video Chat to get an estimate or consultation for a project on #{ booking.booking_date.try(:strftime, "%m-%d-%Y") } and #{ booking.user_time.strftime("%I:%M %p") }. Please Download Mobile APP for IOS APP  ( #{ mobile_app_url('ios-pro') } ) or Android APP ( #{ mobile_app_url('android-pro') } ) to connect to your video chat."
  end

  def self.send_reminder_sms_to_user(booking)
    new.send_reminder_sms_to_user(booking)
  end

  def send_reminder_sms_to_user(booking)
    body = send_reminder_sms_to_user_body(booking)
    receivers = booking.user.business? ? booking.user.all_business_users.notification_allowed.map(&:phone_number) : [booking.user.phone_number]
    receivers.each do |receiver|
      send_message(receiver, body) unless receiver.blank?
      sleep 1 if receivers.size > 1 && ( Rails.env.production? || Rails.env.staging? )
    end
  end

  def send_reminder_sms_to_user_body(booking)
    shortened = Shortener::ShortenedUrl.generate(chat_url(booking.professional_token))
    link = short_url(shortened)
    if booking.user.business?
      return "Hello #{ booking.user } your Video Chat with your New Customer Starts In 5-Minutes. Please Join the Video Chat from your Video Chat a Pro Mobile APP for IOS APP  ( #{ mobile_app_url('ios-pro') } ) or Android APP ( #{ mobile_app_url('android-pro') } ) to connect to your video chat."
    else
      return "Hello #{ booking.user } your video chat starts in 5-minute. Please Join from the Video Chat a Pro Mobile APP for IOS APP  ( #{ mobile_app_url('ios-pro') } ) or Android APP ( #{ mobile_app_url('android-pro') } ) to connect to your video chat."
    end
  end

  def self.send_otp_to_client(phone_number, otp)
    new.send_otp_to_client(phone_number, otp)
  end

  def send_otp_to_client(phone_number, otp)
    body = "Client login OTP is : #{otp}"
    send_message(phone_number, body)
  end

  def self.send_sms_to_client(booking)
    new.send_sms_to_client(booking)
  end

  def send_sms_to_client(booking)
    body = send_sms_to_client_body(booking)
    send_message(booking.client.phone_number, body)
  end

  def send_sms_to_client_body(booking)
    shortened = Shortener::ShortenedUrl.generate(chat_url(booking.client_token))
    link = short_url(shortened)
    "Hello #{ booking.client } thank you for choosing to Video Chat with #{ booking.user }. Please Download the Video Chat a Pro Mobile APP. IOS APP ( #{ mobile_app_url('ios-client') } ) or Android APP ( #{ mobile_app_url('android-client') } ) to connect to your Video Chat."
  end

  def self.send_reminder_sms_to_client(booking)
    new.send_reminder_sms_to_client(booking)
  end

  def send_reminder_sms_to_client(booking)
    shortened = Shortener::ShortenedUrl.generate(chat_url(booking.client_token))
    link = short_url(shortened)
    if booking.user.business?
      body = "Hello #{ booking.client } your video chat starts in 5-Minutes. Please Join from Your New Video Chat a Pro Mobile APP for IOS APP ( #{ mobile_app_url('ios-client') } ) or Android APP ( #{ mobile_app_url('android-client') } ) to connect to your video chat."
    else
      body = "Hello #{ booking.client } your Video Chat Starts In 5 Minutes. Please Join the Video Chat from Your Video Chat A Pro Mobile APP for IOS APP ( #{ mobile_app_url('ios-client') } ) or Android APP ( #{ mobile_app_url('android-client') } ) to connect to your video chat."
    end
    send_message(booking.client.phone_number, body)
  end

  def self.send_sms_from_business(video_chat)
    new.send_sms_from_business(video_chat)
  end

  def send_sms_from_business(video_chat)
    shortened = Shortener::ShortenedUrl.generate(chat_url(video_chat.session_id))
    link = short_url(shortened)
    body = "#{video_chat.sender.name} sent you an Video Chat to begin at #{video_chat.recipient_time.strftime("%m-%d-%Y %I:%M %P %Z")}. Client Mobile APP for IOS APP ( #{ mobile_app_url('ios-client') } ) or Android APP ( #{ mobile_app_url('android-client') } ) to connect to your video chat."
    pro_body = "#{video_chat.sender.name} sent you an Video Chat to begin at #{video_chat.recipient_time.strftime("%m-%d-%Y %I:%M %P %Z")}. Pro Mobile APP for IOS APP  ( #{ mobile_app_url('ios-pro') } ) or Android APP ( #{ mobile_app_url('android-pro') } ) to connect to your video chat. "

    body = pro_body if video_chat&.receiver&.employee?

    receivers = video_chat.phone_number.split(/[,;]/) << video_chat.receiver.try(:phone_number)
    sender = video_chat.sender&.phone_number

    send_message(sender, pro_body) if sender.present?

    if receivers.present?
      receivers.compact.uniq.each do |receiver|
        send_message(receiver, body)
        sleep 1 if receivers.size > 1 && ( Rails.env.production? || Rails.env.staging? )
      end
    end
  end

  def self.send_reminder_sms_from_business(video_chat)
    new.send_reminder_sms_from_business(video_chat)
  end

  def send_reminder_sms_from_business(video_chat)
    body = "Your In House Video Chat is scheduled to begin in 5 minutes. Client Mobile APP for IOS APP ( #{ mobile_app_url('ios-client') } ) or Android APP ( #{ mobile_app_url('android-client') } ) to connect to your video chat."
    pro_body = "Your In House Video Chat is scheduled to begin in 5 minutes. Pro Mobile APP for IOS APP  ( #{ mobile_app_url('ios-pro') } ) or Android APP ( #{ mobile_app_url('android-pro') } ) to connect to your video chat. "

    receivers = video_chat.phone_number.split(/[,;]/) << video_chat.receiver.try(:phone_number)
    sender = video_chat.sender&.phone_number

    send_message(sender, pro_body) if sender.present?

    if receivers.present?
      receivers.compact.uniq.each do |receiver|
        send_message(receiver, body)
        sleep 1 if receivers.size > 1 && ( Rails.env.production? || Rails.env.staging? )
      end
    end
  end

  # def send_reminder_sms_from_business_body(video_chat)
  #   shortened = Shortener::ShortenedUrl.generate(chat_url(video_chat.session_id))
  #   link = short_url(shortened)
  #   body = "Your In House Video Chat is scheduled to begin in 5 minutes. Press here #{link} to join."
  # end

  def send_message(to, body)
    self.class.send_message(to, body)
  end

  def self.send_message(to, body)
    SMSClient.send(to: to, text: body)
  end

  def self.send_sms_app_link_to_user(receiver)
    new.send_sms_app_link_to_user(receiver)
  end

  def send_sms_app_link_to_user(receiver)
    body = "Here are the links to install Videochatapro Mobile App. Android Link : #{ mobile_app_url('android-pro') } & IOS Link : #{ mobile_app_url('ios-pro') }"
    send_message(receiver, body) unless receiver.blank?
  end

  class SMSClient
    attr_reader :from, :to, :text

    def initialize(from, to, text)
      @from = from
      @to = sanitize(to)
      @text = text
    end

    def self.send(to:, text:, from: phone_number)
      new(from, to, text).send
    end

    def self.test_sms(to:, text:)
      new(phone_number, to, text).send
    end

    def send
      if Rails.env.production? || Rails.env.staging?
        send_prod
      else
        send_dev
      end
    end

    def self.config
      @@config ||= SmsSetting.first
    end

    def self.phone_number
      config.phone_number
    end

    def self.api_key
      config.api_key
    end

    def self.api_secret
      config.api_secret
    end

    private

    def send_dev
      GenericMailer.development_sms(from: from, to: to, text: text).deliver_now
    end

    def send_prod
      client = Nexmo::Client.new(
        api_key: self.class.config.api_key,
        api_secret: self.class.config.api_secret
      )

      begin
        response = client.sms.send(from: from, to: to, text: text)
        if response.messages.first.status == "0"
          Rails.logger.warn "Sent message id: #{response.messages.first.message_id}"
        else
          Rails.logger.warn "SMS Error: #{response.messages.first.error_text}"
        end
      rescue => e
        Rails.logger.warn "SMS Error: #{e.message}"
      end
    end

    def sanitize(to)
      Phonelib.parse(to).sanitized
    rescue
      to
    end
  end
end
