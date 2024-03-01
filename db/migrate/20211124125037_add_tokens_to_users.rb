class AddTokensToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tokens, :json, default: {}
    add_column :users, :provider, :string, default: "email"
    add_column :users, :uid, :string, :null => false, :default => ""
  end
end
