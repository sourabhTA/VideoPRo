ActiveAdmin.register ScheduledService do
  actions :all, except: [:new, :edit, :destroy]
  config.filters = false
  includes :user

  index do
    column :user
    column :property_type
    column :home_type
    column :your_name
    column :owner_name
    actions
  end
end
