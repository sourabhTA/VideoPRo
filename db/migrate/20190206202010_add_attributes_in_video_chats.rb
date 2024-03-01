class AddAttributesInVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :email, :string
    add_column :video_chats, :business_id, :integer
    add_column :video_chats, :subject, :string
    add_column :video_chats, :body, :text
  end
end
