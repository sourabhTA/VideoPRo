class ChangeFcmTokenToArrayInUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :fcm_token, :string
    add_column :users, :fcm_token, :text, array: true, default: []
  end
end
