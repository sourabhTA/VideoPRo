class AddStripeSubscriptionIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :stripe_subscription_id, :string
  end
end
