class AddUnsubscribeAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unsubscribe_at, :datetime
  end
end
