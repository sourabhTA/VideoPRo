class CreateLicenseInformations < ActiveRecord::Migration[5.1]
  def change
    create_table :license_informations do |t|
      t.integer :user_id
      t.integer :category_id
      t.string :license_number
      t.string :state_issued
      t.date :expiration_date

      t.timestamps
    end
  end
end
