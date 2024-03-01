class AddFinishChatDelayjobIdToVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :finish_chat_delayjob_id, :integer
  end
end
