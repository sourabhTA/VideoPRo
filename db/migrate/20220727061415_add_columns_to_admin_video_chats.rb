class AddColumnsToAdminVideoChats < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_video_chats, :second_client_token, :uuid, null: false, unique: true, default:  "uuid_generate_v4()"
  end
end
