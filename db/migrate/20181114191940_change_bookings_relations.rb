class ChangeBookingsRelations < ActiveRecord::Migration[5.1]
  def change
    remove_column :bookings, :pro_id, :integer
    add_column    :bookings, :client_id, :integer
  end
end
