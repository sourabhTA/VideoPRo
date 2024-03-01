ActiveAdmin.register AutoEmail do
  permit_params :category_id, :segment, :role, :number_of_days, :subject, :pre_header, :image,
    :content, :button_text, :button_url, :automation, :for_all

  config.filters = false

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :automation, label: "Repeat", as: :boolean
      f.input :for_all, label: "For All Categories", as: :boolean
      f.input :category_id, as: :select, collection: Category.all.map { |p| [p.name, p.id] }, prompt: "Select Category"
      f.input :segment, as: :select, collection: Category::SEGMENTS, prompt: "Select Segment"
      f.input :role, as: :select, collection: ["pro", "business", "customer"], prompt: "Select Role"
      f.input :number_of_days
      f.input :subject
      f.input :pre_header, input_html: {class: "tinymce"}
      f.input :content, input_html: {class: "tinymce"}
      f.input :image
      f.input :button_text
      f.input :button_url
    end
    f.actions
  end

  show do
    @auto_email = AutoEmail.find_by id: params[:id]

    attributes_table do
      row(:category) do
        @auto_email.category.try(:name)
      end
      row(:image) do
        image_tag @auto_email.image.url, width: "75px" unless @auto_email.image.url.blank?
      end
      row("For All Categories") do
        @auto_email.for_all
      end
      row("Repeat") do
        @auto_email.automation
      end
      row(:number_of_days) do
        @auto_email.number_of_days
      end
      row(:segment) do
        @auto_email.segment
      end
      row(:role) do
        @auto_email.role
      end
      row(:pre_header) do
        raw @auto_email.pre_header
      end
      row(:subject) do
        @auto_email.subject
      end
      row(:content) do
        raw @auto_email.content
      end
      row(:button_text) do
        @auto_email.button_text
      end
      row(:button_url) do
        @auto_email.button_url
      end
    end
  end

  index do
    all_users = User.all.have_tokens
    all_customers = Client.all.have_tokens

    column :category_id do |auto_email|
      auto_email.category.try(:name)
    end
    column :segment do |auto_email|
      auto_email.segment
    end
    column :role
    column "Total users with criteria" do |auto_email|
      if auto_email.for_all
        case auto_email.role
        when "pro" # all pros without categories
          all_users.pros.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).count
        when "business" # all business without categories
          all_users.businesses.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).count
        when "customer" # all customers
          all_customers.email_subscribed.count
        else
          # all users without categories and without role
          all_users.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).count
          # all customers
          all_customers.email_subscribed.count
        end
      else
        case auto_email.role
        when "pro"
          all_users.pros.email_subscribed.trades(auto_email.category_id).send(auto_email.segment.downcase.parameterize.underscore.to_sym).count
        when "business"
          all_users.businesses.email_subscribed.trades(auto_email.category_id).send(auto_email.segment.downcase.parameterize.underscore.to_sym).count
        when "customer"
          all_customers.email_subscribed.count
        end
      end
    end
    column :number_of_days
    column :subject
    column :created_at
    column "Repeat" do |auto_email|
      auto_email.automation
    end
    column "For All Categories" do |auto_email|
      auto_email.for_all
    end
    actions
  end
end
