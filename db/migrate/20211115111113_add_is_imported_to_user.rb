class AddIsImportedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_imported, :boolean, default: false
  end
end
