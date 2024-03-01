class AddConnectionIdToVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :connection_id, :string
  end
end
