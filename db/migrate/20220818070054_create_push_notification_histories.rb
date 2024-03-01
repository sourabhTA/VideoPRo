class CreatePushNotificationHistories < ActiveRecord::Migration[5.2]
  def change
     create_table :push_notification_histories do |t|
       t.text :receivers_email, array: true, default: []
       t.timestamps
     end
  end
end
