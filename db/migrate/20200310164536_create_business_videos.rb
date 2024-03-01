class CreateBusinessVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :business_videos do |t|
      t.integer :user_id
      t.string :video

      t.timestamps
    end
  end
end
