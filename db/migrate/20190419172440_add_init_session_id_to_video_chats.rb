class AddInitSessionIdToVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :init_session_id, :string
  end
end
