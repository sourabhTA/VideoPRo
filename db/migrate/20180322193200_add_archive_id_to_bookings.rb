class AddArchiveIdToBookings < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :archive_id, :string
  end
end
