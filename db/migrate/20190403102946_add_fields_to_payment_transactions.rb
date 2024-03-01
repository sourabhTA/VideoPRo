class AddFieldsToPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :balance_transaction_id, :string
    add_column :payment_transactions, :stripe_fee, :decimal
    add_column :payment_transactions, :net_amount, :decimal
  end
end
