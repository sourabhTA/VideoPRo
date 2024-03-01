class CreateNotificationRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_recipients do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :notification, index: true, foreign_key: true

      t.boolean :is_read, default: false
      t.timestamps
    end
  end
end
