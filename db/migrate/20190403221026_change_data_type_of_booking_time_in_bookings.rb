class ChangeDataTypeOfBookingTimeInBookings < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :booking_time
    add_column    :bookings, :booking_time, :datetime, default: DateTime.now
  end
end
