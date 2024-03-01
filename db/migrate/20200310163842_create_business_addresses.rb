class CreateBusinessAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :business_addresses do |t|
      t.integer :user_id
      t.string :city
      t.string :zip
      t.float :price

      t.timestamps
    end
  end
end
