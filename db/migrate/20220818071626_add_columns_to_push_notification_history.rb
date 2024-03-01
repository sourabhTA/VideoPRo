class AddColumnsToPushNotificationHistory < ActiveRecord::Migration[5.2]
  def change
    add_column :push_notification_histories, :run_at_time, :string
    add_column :push_notification_histories, :time_zone, :string
    add_column :push_notification_histories, :title, :string
    add_column :push_notification_histories, :message_body, :string
    add_column :push_notification_histories, :user_type, :string
   end
end
