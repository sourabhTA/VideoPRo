class ChangeLockedByAdminDefaultInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :locked_by_admin, false
  end
end
