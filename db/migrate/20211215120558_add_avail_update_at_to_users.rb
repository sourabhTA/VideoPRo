class AddAvailUpdateAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :avail_update_at, :datetime
  end
end
