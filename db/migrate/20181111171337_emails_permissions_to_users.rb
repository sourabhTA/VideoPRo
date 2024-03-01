class EmailsPermissionsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email_permissions, :boolean, default: true
  end
end
