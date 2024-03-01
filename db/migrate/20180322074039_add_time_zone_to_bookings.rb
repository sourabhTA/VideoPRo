class AddTimeZoneToBookings < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :time_zone, :string
  end
end
