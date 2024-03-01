class AddCallTimeBookedPaymentTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :call_time_booked, :integer
  end
end
