class AddTimeZoneToVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :time_zone, :string
  end
end
