class AddSlugToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :slug, :string
    add_index :bookings, :slug, unique: true
  end
end
