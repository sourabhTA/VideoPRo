class AddChargeIdPaymentTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :charge_id, :string
  end
end
