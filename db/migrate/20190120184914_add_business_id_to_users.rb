class AddBusinessIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :business_id, :integer
    add_column :users, :all_notifications, :boolean, default: true
  end
end
