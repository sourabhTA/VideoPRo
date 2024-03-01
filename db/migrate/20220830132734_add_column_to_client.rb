class AddColumnToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :mobile_login, :boolean, default: false
  end
end
