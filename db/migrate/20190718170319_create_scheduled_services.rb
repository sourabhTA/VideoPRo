class CreateScheduledServices < ActiveRecord::Migration[5.2]
  def change
    create_table :scheduled_services do |t|
      t.integer :user_id
      t.string :property_type
      t.string :home_type
      t.integer :property_age
      t.string :property_address
      t.string :owner_name
      t.string :your_name
      t.string :phone_number
      t.string :email_address
      t.string :scheduled_time
      t.text :explaination

      t.timestamps
    end
  end
end
