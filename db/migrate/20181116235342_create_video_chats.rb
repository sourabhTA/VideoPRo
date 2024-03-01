class CreateVideoChats < ActiveRecord::Migration[5.2]
  def change
    create_table :video_chats do |t|
      t.integer :user_id
      t.string :name
      t.string :session_id
      t.string :archive_id

      t.timestamps
    end
  end
end
