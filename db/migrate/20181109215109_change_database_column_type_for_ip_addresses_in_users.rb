class ChangeDatabaseColumnTypeForIpAddressesInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :current_sign_in_ip, :string
    change_column :users, :last_sign_in_ip, :string
  end
end
