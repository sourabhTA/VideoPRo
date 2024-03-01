class AddTimeSpentToVideoChats < ActiveRecord::Migration[5.2]
  def change
    # store chat time used in seconds
    add_column :video_chats, :time_used, :bigint, default: 0
  end
end
