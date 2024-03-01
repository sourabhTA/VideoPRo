class AddGoogleMyBusinessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :google_my_business, :string
  end
end
