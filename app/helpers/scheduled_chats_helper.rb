module ScheduledChatsHelper
  require 'fcm'

  def seconds_to_hms(sec)
    "%02d:%02d:%02d" % [sec / 3600, sec / 60 % 60, sec % 60]
  end

  # call method
  # fcm_push_notification(userToken,"title","message",action,invokeApp)

  def fcm_push_notification(userToken, title, message, action, invokeApp, user_type="user") 
    if user_type == "client"
      fcm_client = FCM.new(ENV["FCM_SERVER_KEY_CLIENT"]) # set your FCM_SERVER_KEY
    else
      fcm_client = FCM.new(ENV["FCM_SERVER_KEY"]) # set your FCM_SERVER_KEY  
    end
    
    options = { priority: 'high',
      data: { message: message, title: title, action: action, invokeApp: invokeApp },
      notification: { body: message, title: title, sound: 'default'}
    }
    registration_ids = userToken
    registration_ids.each_slice(20) do |registration_id|
    response = fcm_client.send(registration_id, options)
    puts response
    end
    
  end

end
