class AddColumnToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :client_email, :string, default: ""
  end
end
