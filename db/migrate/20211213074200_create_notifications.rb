class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :title,        null: false,     default: ""
      t.string :message,      null: false,     default: ""
      t.boolean :is_read,     default: false
      t.integer :from_id
      t.integer :to_id
      t.integer :videochat_id
      t.integer :booking_id

      t.timestamps
    end
  end
end
