class AddTimeUsedToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :time_used, :integer, default: 0
  end
end
