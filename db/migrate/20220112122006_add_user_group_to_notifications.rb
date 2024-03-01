class AddUserGroupToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :user_group, :string, default: ""
  end
end
