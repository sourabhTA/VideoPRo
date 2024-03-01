class CreateBlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :blogs do |t|
      t.string :title
      t.text :content
      t.integer :blog_category_id
      t.string :image
      t.string :video_url
      t.datetime :published_at

      t.timestamps
    end
  end
end
