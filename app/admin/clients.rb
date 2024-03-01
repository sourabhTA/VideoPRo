ActiveAdmin.register Client do
  actions :all, except: [:new, :edit, :destroy]

  filter :first_name
  filter :last_name
  filter :email
  filter :phone_number
  filter :created_at

  index do
    selectable_column

    column :first_name
    column :last_name
    column :email
    actions
  end

  show do
    attributes_table do
      row(:first_name) do
        resource.first_name
      end
      row(:last_name) do
        resource.last_name
      end
      row(:email) do
        resource.email
      end
      row(:phone_number) do
        resource.phone_number
      end
      row(:booking) do
        resource.booking
      end
    end
  end
end
