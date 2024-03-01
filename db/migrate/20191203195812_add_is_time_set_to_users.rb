class AddIsTimeSetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_time_set, :boolean, default: false
  end
end
