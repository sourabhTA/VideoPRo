class AddInitSessionIdToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :init_session_id, :string
  end
end
