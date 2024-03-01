class AddCustomerIdInClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :customer_id, :string
  end
end
