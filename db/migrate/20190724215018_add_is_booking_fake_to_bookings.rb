class AddIsBookingFakeToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :is_booking_fake, :boolean, default: false
  end
end
