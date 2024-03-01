class AddFreeOfChargeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :free_of_charge, :boolean, default: false
  end
end
