class AddIsHiddenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_hidden, :boolean, default: false
  end
end
