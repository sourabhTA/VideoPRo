class AddSlugToBlogCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :blog_categories, :slug, :string, default: ""
  end
end
