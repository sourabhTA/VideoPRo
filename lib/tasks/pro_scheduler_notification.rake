namespace :pro_scheduler_notification do

  desc "send out notifications"

  task send_messages: :environment do
    PushNotificationHistory.where("created_at <= ?", Time.current - 3.days).destroy_all
  # push_notification = PushNotificationModule.last
    PushNotificationModule.all.each do|pnm|

    # dow = Time.current.in_time_zone(time_zone).strftime("%A").downcase
    dow = Date.today.strftime("%A").downcase

      if pnm["#{dow}"]
        pnm.send_push_notification_pst
        pnm.send_push_notification_mst
        pnm.send_push_notification_cst
        pnm.send_push_notification_est
      end

    end
  end
end

