class AddColumnsInVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :booked_time, :integer
  end
end
