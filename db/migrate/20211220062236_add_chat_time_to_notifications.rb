class AddChatTimeToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :chat_time, :datetime
  end
end
