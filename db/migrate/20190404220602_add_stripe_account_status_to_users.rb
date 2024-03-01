class AddStripeAccountStatusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_account_status, :string, default: "pending"
  end
end
