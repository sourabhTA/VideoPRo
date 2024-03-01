class CreateAdminVideoChats < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_video_chats do |t|
      t.string :name
      t.string :session_id
      t.string :archive_id

      t.timestamps
    end
  end
end
