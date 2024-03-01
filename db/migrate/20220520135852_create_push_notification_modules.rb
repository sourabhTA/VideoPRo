class CreatePushNotificationModules < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notification_modules do |t|
      t.integer :user_type 
      t.string :title
      t.string :message_body
      t.timestamps
    end
  end
end
