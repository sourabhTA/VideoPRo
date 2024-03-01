class AddCustomerAmountToPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :customer_amount, :decimal
  end
end
