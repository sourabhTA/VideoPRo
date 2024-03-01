class AddColumnsInVideoChat < ActiveRecord::Migration[5.2]
  def change
      add_column :video_chats, :delayjob_id, :integer
      add_column :video_chats, :is_expired, :boolean, default: false
  end
end
