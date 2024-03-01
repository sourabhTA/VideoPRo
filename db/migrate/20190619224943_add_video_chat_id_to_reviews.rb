class AddVideoChatIdToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :video_chat_id, :integer
  end
end
