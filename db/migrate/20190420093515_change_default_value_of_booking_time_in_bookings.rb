class ChangeDefaultValueOfBookingTimeInBookings < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:bookings, :booking_time, nil)
  end
end
