class AddColumnToPaymentTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :amount_refund, :decimal
  end
end
