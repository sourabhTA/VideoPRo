class AddTimingsToVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :timings, :datetime
  end
end
