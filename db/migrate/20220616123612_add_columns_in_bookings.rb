class AddColumnsInBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :fake_booked_time, :integer
  end
end
