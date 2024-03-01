class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.integer :pro_id
      t.integer :amount
      t.date :booking_date
      t.time :booking_time
      t.string :city
      t.string :state
      t.text :issue
      t.text :video_chat_url
      t.string  :transaction_code
      t.string :transaction_status

      t.timestamps
    end
  end
end
