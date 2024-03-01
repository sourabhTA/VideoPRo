class AddEmailAttributesToAdminVideoChats < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_video_chats, :email, :string
    add_column :admin_video_chats, :subject, :string
    add_column :admin_video_chats, :body, :text
  end
end
