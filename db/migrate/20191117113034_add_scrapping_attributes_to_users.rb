class AddScrappingAttributesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :scrapped_link, :string
  end
end
