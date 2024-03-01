class AddIsVanPaidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_van_paid, :boolean, default: false
  end
end
