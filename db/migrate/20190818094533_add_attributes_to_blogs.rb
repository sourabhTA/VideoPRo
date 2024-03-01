class AddAttributesToBlogs < ActiveRecord::Migration[5.2]
  def change
    add_column :blogs, :meta_keywords, :text
    add_column :blogs, :meta_description, :text
    add_column :blogs, :slug, :string
  end
end
