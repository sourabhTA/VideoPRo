class UpdateVideoChatColumns < ActiveRecord::Migration[5.2]
  def change
    add_column    :video_chats, :from_id, :integer
    add_column    :video_chats, :to_id, :integer
  end
end
