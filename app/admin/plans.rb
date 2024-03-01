ActiveAdmin.register Plan do
  actions :index, :new, :create, :show, :edit, :update, :destroy
  config.filters = false

  show do |record|
    attributes_table do
      row :name
      row :display_price
      row :minutes_allowed
      row :is_active
    end
    panel "Features" do
      table_for record.features do
        column(:plan)
        column(:title)
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Plan" do
      f.input :name
      f.input :display_price
      f.input :minutes_allowed, as: :number
      f.input :is_active

      f.has_many :features do |app_f|
        app_f.input :title
        if !app_f.object.new_record?
          # show the destroy checkbox only if it is an existing appointment
          # else, there's already dynamic JS to add / remove new appointments
          app_f.input :_destroy, as: :boolean, label: "Destroy?"
        end
      end
    end
    f.actions
  end

  index do
    column :name
    column :display_price
    column :minutes_allowed
    column "Stripe ID", :stripe_id
    column "Active", :is_active
    actions
  end

  controller do
    def create
      @plan = Plan.new(plan_params)
      if @plan.save_on_stripe
        flash[:notice] = "Plan created successfully!"
        redirect_to collection_url
      else
        flash[:error] = "Plan was not created!"
        render :new
      end
    end

    def update
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts plan_params.inspect
      if resource.update_on_stripe(plan_params)
        flash[:notice] = "Plan updated successfully!"
        redirect_to collection_url
      else
        flash[:error] = "Plan was not updated!"
        render :edit
      end
    end

    def destroy
      if resource.delete_on_stripe
        flash[:notice] = "Plan deleted successfully!"
        redirect_to collection_url
      else
        flash[:error] = "Plan was not deleted!"
        render :edit
      end
    end

    def plan_params
      params.require(:plan).permit(:name, :display_price, :minutes_allowed, :is_active, features_attributes: [:id, :plan_id, :title, :_destroy])
    end
  end
end
