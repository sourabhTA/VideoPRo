class AddSessionIdToBookings < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :session_id, :string
  end
end
