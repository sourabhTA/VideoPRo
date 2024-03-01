class AddClaimsAttributeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_claimed, :boolean, default: false
    add_column :users, :claim_approved, :boolean, default: false
  end
end
