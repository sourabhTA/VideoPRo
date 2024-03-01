class CreateClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :claims do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.boolean :is_approved

      t.timestamps
    end
    add_index :claims, [:user_id, :email], unique: true
  end
end
