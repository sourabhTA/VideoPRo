class AddLatitudeAndLongitudeToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :latitude, :float
    add_column :bookings, :longitude, :float
  end
end
