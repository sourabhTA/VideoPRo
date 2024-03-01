class PushNotification
  require 'fcm'

  include Rails.application.routes.url_helpers

  def self.send_notification(video_chat)
  	new.send_notification(video_chat)
  end

  def send_notification(video_chat)
    from = User.find(video_chat.from_id)
    to = User.find(video_chat.to_id) if video_chat.to_id

    inhouse_push_notification(from,to,video_chat)
  end

  def self.booking_notification(booking)
  	new.booking_notification(booking)
  end

  def booking_notification(booking)
    from = User.find(booking.user_id)

    inhouse_push_notification(from,nil,booking)
  end

  def inhouse_push_notification(from, to, chat)
    recipient = client_email(to, chat)
    message = "Hi #{from.name}, your video chat with #{recipient} begins in 5 minutes."
    # message = "Hello #{from.name} your in house video chat starts in 5 minutes"
    chat_id, chat_time = chat.class.name == "VideoChat" ? ["videochat_id",chat.timings] : ["booking_id",chat.booking_time]
    Notification.create(title: "Video chat 5 minute reminder",message: message,from_id: to&.id, to_id: from&.id, "#{chat_id}": chat.id, chat_time: chat_time)
    fcm_push_notification(from.fcm_token, "5 minute reminder", message) if from.fcm_token.present?

    if to.present?
      message = "Your video chat with #{from.name} begins in 5 minutes."
      # message = "Hello #{to.name} your in house video chat starts in 5 minutes"
      Notification.create(title: "Video chat 5 minute reminder",message: message,from_id: from&.id, to_id: to&.id, "#{chat_id}": chat.id, chat_time: chat_time)
      fcm_push_notification(to.fcm_token, "5 minute reminder", message) if to.fcm_token.present?
    end
  end

  def client_email(to, chat)
    if chat.class.to_s == "Booking"
      return chat.client.full_name
    else
      return to.present? ? to.name : chat.email
    end
  end

  def fcm_push_notification(userToken, title, message, user_type="user")
    if user_type == "client"
      fcm_client = FCM.new(ENV["FCM_SERVER_KEY_CLIENT"]) # set your FCM_SERVER_KEY
    else
      fcm_client = FCM.new(ENV["FCM_SERVER_KEY"]) # set your FCM_SERVER_KEY  
    end  
    options = { priority: 'high',
                data: { message: message, title: title, action: nil, invokeApp: :true },
                notification: { body: message, title: title, sound: 'default'}
              }
    registration_ids = userToken

    registration_ids.each_slice(20) do |registration_id|
      response = fcm_client.send(registration_id, options)
      puts "Notification send to mobile success------------------------\n-----#{response}-----------"
    end
  end

end