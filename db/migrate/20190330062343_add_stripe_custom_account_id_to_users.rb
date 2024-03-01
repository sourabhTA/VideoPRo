class AddStripeCustomAccountIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_custom_account_id, :string
  end
end
