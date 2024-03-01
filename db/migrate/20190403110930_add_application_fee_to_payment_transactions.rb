class AddApplicationFeeToPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :application_fee, :decimal
  end
end
