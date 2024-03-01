class AddIsFeaturedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_featured, :boolean, default: false
  end
end
