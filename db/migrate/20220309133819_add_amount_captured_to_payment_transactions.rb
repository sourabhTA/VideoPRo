class AddAmountCapturedToPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :amount_captured, :decimal
  end
end
