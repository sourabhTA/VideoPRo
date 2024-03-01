class AddEmailSubscriptionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_subscription, :boolean, default: true
    add_column :clients, :email_subscription, :boolean, default: true
  end
end
