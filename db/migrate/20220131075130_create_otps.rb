class CreateOtps < ActiveRecord::Migration[5.2]
  def change
    create_table :otps do |t|
      t.string :email, null: false
      t.integer :otp

      t.timestamps
    end
  end
end
