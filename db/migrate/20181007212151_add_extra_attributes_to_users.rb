class AddExtraAttributesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :profile_completed, :boolean, default: false
    add_column :users, :stripe_customer_id, :string
    add_column :users, :subscribed_at, :datetime
    add_column :users, :subscription_expires_at, :datetime
    add_column :users, :plan_id, :integer
  end
end
