class AddStripeTokenToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :stripeToken, :string
  end
end
