class AddBusinessAddressToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :business_address, :string
  end
end
