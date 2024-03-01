class AddIsInternalToVideChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :is_internal, :boolean, default: true
  end
end
