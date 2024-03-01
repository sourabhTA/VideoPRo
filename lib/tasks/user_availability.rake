namespace :send_notification do
  desc "Send Notification to Pro User."
  task availability: :environment do
    User.pros.each do |user|
      title = "Set schedule notification"
      message = "Are you available for video chats today?"

      if user.fcm_token.present?
        fcm_client = FCM.new(ENV["FCM_SERVER_KEY"]) # set your FCM_SERVER_KEY
        options = { priority: 'high',
                    data: { message: message, title: title, actions: ["Yes","No"], invokeApp: false },
                    notification: { body: message,sound: 'default'}
                  }
        registration_ids = [user.fcm_token]
        # A registration ID looks something like: “dAlDYuaPXes:APA91bFEipxfcckxglzRo8N1SmQHqC6g8SWFATWBN9orkwgvTM57kmlFOUYZAmZKb4XGGOOL9wqeYsZHvG7GEgAopVfVupk_gQ2X5Q4Dmf0Cn77nAT6AEJ5jiAQJgJ_LTpC1s64wYBvC”
        registration_ids.each_slice(20) do |registration_id|
          response = fcm_client.send(registration_id, options)
          puts response
        end
      end
    end

  end
end

