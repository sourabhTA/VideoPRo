class CreatePaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transactions do |t|
      t.integer :booking_id
      t.decimal :amount, default: 0
      t.integer :time_used, default: 0
      t.string :transaction_code
      t.string :transaction_status
      t.string :transaction_status_local, default: "unpaid"

      t.timestamps
    end
  end
end
