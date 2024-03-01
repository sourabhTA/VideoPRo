ActiveAdmin.register Review do
  actions :all, except: [:new, :create]
  config.filters = false
  permit_params :rating, :comment, :reviewer_name
  includes :client, :booking, :user

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Review Details" do
      f.input :rating
      f.input :comment
      f.input :reviewer_name
    end

    f.actions
  end
end
