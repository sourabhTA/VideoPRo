class AddFcmtokenInClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :fcm_token, :text, array: true, default: []
  end
end
