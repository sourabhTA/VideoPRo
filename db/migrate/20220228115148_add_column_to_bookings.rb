class AddColumnToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :delayjob_id, :integer
    add_column :bookings, :is_expired, :boolean, default: false
    add_column :bookings, :connection_id, :string
  end
end
