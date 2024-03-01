class AddAttributesToScheduledServices < ActiveRecord::Migration[5.2]
  def change
    change_column :scheduled_services, :property_age, :string
    add_column :scheduled_services, :city, :string
    add_column :scheduled_services, :state, :string
    add_column :scheduled_services, :zip, :string
  end
end
