class ChangeColumnToPaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :payment_transactions, :call_time_booked, :integer, :default => 0
  end
end
