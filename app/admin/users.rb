ActiveAdmin.register User do
  permit_params :name, :phone_number, :business_number, :email, :password, :password_confirmation, :picture, :rate,
    :category_id, :business_address, :email_permissions, :license_type, :description, :city,
    :state, :zip, :availability, :business_website, :time_zone, :locked_by_admin, :is_featured,
    :is_hidden, :address, :is_verified, :video_url, :is_time_set, :is_claimed, :claim_approved,
    :facebook_url, :google_my_business, :twitter_url, :instagram_url, :youtube_url, :linkedin_url,
    :is_monday_on, :is_tuesday_on, :is_wednesday_on, :is_thursday_on, :is_friday_on, :is_saturday_on,
    :is_sunday_on, :monday_start_time, :monday_end_time, :tuesday_start_time, :tuesday_end_time, :free_of_charge,
    :wednesday_start_time, :wednesday_end_time, :thursday_start_time, :thursday_end_time, :friday_start_time,
    :friday_end_time, :saturday_start_time, :saturday_end_time, :sunday_start_time, :sunday_end_time,
    :stripe_subscription_id, :monday_break_start_time, :monday_break_end_time, :tuesday_break_start_time,
    :tuesday_break_end_time, :wednesday_break_start_time, :wednesday_break_end_time, :thursday_break_start_time,
    :thursday_break_end_time, :friday_break_start_time, :friday_break_end_time, :saturday_break_start_time,
    :saturday_break_end_time, :sunday_break_start_time, :sunday_break_end_time, :product_knowledge, :specialties,
    license_informations_attributes: [:id, :user_id, :category_id, :license_number, :state_issued, :expiration_date, :_destroy],
    business_addresses_attributes: [:id, :user_id, :city, :zip, :price, :url, :_destroy],
    business_pictures_attributes: [:id, :user_id, :picture, :alt, :description, :_destroy],
    business_videos_attributes: [:id, :user_id, :video, :alt, :description, :_destroy]

  actions :index, :show, :new, :create, :update, :edit
  actions :all, except: [:new]
  filter :slug
  filter :name
  filter :phone_number
  filter :business_number
  filter :email
  filter :address
  filter :rate
  filter :category
  filter :business_address
  filter :email_permissions
  filter :description
  filter :city
  filter :state
  filter :zip
  filter :business_website
  filter :time_zone
  filter :locked_by_admin
  filter :free_of_charge
  filter :is_featured
  filter :is_hidden
  filter :is_monday_on
  filter :is_tuesday_on
  filter :is_wednesday_on
  filter :is_thursday_on
  filter :is_friday_on
  filter :is_saturday_on
  filter :is_sunday_on

  scope :pros, default: true
  scope "Paid Businesses", :subscribed_and_paid
  scope "All Businesses", :all_businesses
  scope "Imported Business", :imported_businesses
  scope "Featured Users", :featured
  scope "Imported Confirmed", :imported_confirmed
  scope "Archived Users", :archived_users
  scope "Seems Duplicate", :seems_duplicate

  index do
    column :name
    column :email
    column :phone_number
    column :business_number
    column :confirmed_at
    column :reminder_count

    column "Locking" do |resource|
      link_to (resource.locked_by_admin? ? "Lock Now" : "Unlock Now"), change_lock_status_admin_user_path(resource)
    end

    if params[:scope] == "all_businesses" || params[:scope] == "paid_businesses" || params[:scope] == "imported_business"
      column :plan do |resource|
        resource.plan
      end
      column :address do |resource|
        resource.address
      end
    end

    actions do |resource|
      format = params[:scope] == "archived_users" ? "Restore" : "Delete"
      link_to (params[:scope] == "archived_users" ? "Restore" : "Archive"), restore_user_admin_user_path(resource.slug, type: format), {class: "btn btn-danger"}
    end

  end

  action_item :import_csv, only: :index do
    link_to "Import CSV", import_csv_admin_users_path
  end

  controller do
    def find_resource
      scoped_collection.with_deleted.where(slug: params[:id]).first!
    rescue ActiveRecord::RecordNotFound
      scoped_collection.find(params[:id])
    end

    def update
      super
    rescue ActiveRecord::RecordNotUnique
      flash[:warning] = "Email has already register for another user."
      redirect_to request.url
    rescue Exception => e
      flash[:warning] = "#{e.message}"
      redirect_to request.url
    end
  end

  show do
    @user = User.with_deleted.find_by slug: params[:id]
    attributes_table do
      row(:name) do
        @user.name
      end
      row(:picture) do
        image_tag @user.picture.url(:mini_thumb), width: "75px" unless @user.picture.url.blank?
      end
      row(:email) do
        @user.email
      end
      row(:phone_number) do
        @user.phone_number
      end
      row(:business_number) do
        @user.business_number
      end
      row(:locked_by_admin) do
        @user.locked_by_admin? ? "Locked" : "Un Locked"
      end
      row(:free_of_charge) do
        @user.free_of_charge
      end
      row(:is_featured) do
        @user.is_featured
      end
      row(:is_hidden) do
        @user.is_hidden
      end
      row(:rate) do
        users_rate(@user)
      end
      row(:description) do
        @user.description
      end
      row(:city) do
        @user.city
      end
      row(:state) do
        @user.state
      end
      row(:zip) do
        @user.zip
      end
      row(:specialties) do
        @user.specialties
      end
      row(:product_knowledge) do
        @user.product_knowledge
      end
      row(:video_url) do
        @user.video_url
      end
      if @user.business?
        row(:address) do
          @user.address
        end
        row(:plan) do
          @user.plan
        end
        row(:minutes_left) do
          if @user.business.present?
            (@user.business.seconds_left / 60).round(2)
          else
            0.to_f
          end
        end
        row(:bank_account) do
          @user.bank_accounts.blank? ? "No" : "Yes"
        end
        row(:business_website) do
          @user.business_website
        end
        row(:business_address) do
          @user.business_address
        end
        row(:facebook_url) do
          @user.facebook_url
        end
        row(:google_my_business) do
          @user.google_my_business
        end
        row(:twitter_url) do
          @user.twitter_url
        end
        row(:instagram_url) do
          @user.instagram_url
        end
        row(:youtube_url) do
          @user.youtube_url
        end
        row(:linkedin_url) do
          @user.linkedin_url
        end
      end
    end

    panel "Business Addresses" do
      table_for(@user.business_addresses) do
        column :city
        column :zip
        column :url
      end
    end

    panel "Business Videos" do
      table_for(@user.business_videos) do
        column :video
      end
    end

    panel "Business Pictures" do
      table_for "image" do
        @user.business_pictures.each do |business|
          column do
            image_tag(business.picture.url(:mini_thumb))
          end
        end
      end
    end

    panel "License Information/s" do
      table_for(@user.license_informations) do
        column :category do |lis|
          lis&.category&.name
        end
        column :license_number
        column :id
        column :state_issued
        column :expiration_date
        column :category do |lis|
          link_to "Remove", remove_category_admin_user_path(@user, license_information_id: lis.id), data: {confirm: "Are you sure?"}
        end
      end
    end
    panel "Active Days" do
      table_for @user do
        column :is_monday_on
        column :is_tuesday_on
        column :is_wednesday_on
        column :is_thursday_on
        column :is_friday_on
        column :is_saturday_on
        column :is_sunday_on
      end
    end
    panel "Start Timings" do
      table_for @user do
        column :monday_start_time do |user|
          user.monday_start_time&.strftime("%I:%M %p")
        end

        column :tuesday_start_time do |user|
          user.tuesday_start_time&.strftime("%I:%M %p")
        end

        column :wednesday_start_time do |user|
          user.wednesday_start_time&.strftime("%I:%M %p")
        end

        column :thursday_start_time do |user|
          user.thursday_start_time&.strftime("%I:%M %p")
        end

        column :friday_start_time do |user|
          user.friday_start_time&.strftime("%I:%M %p")
        end

        column :saturday_start_time do |user|
          user.saturday_start_time&.strftime("%I:%M %p")
        end

        column :sunday_start_time do |user|
          user.sunday_start_time&.strftime("%I:%M %p")
        end
      end
    end
    panel "End Timings" do
      table_for @user do
        column :monday_end_time do |user|
          user.monday_end_time&.strftime("%I:%M %p")
        end

        column :tuesday_end_time do |user|
          user.tuesday_end_time&.strftime("%I:%M %p")
        end

        column :wednesday_end_time do |user|
          user.wednesday_end_time&.strftime("%I:%M %p")
        end

        column :thursday_end_time do |user|
          user.thursday_end_time&.strftime("%I:%M %p")
        end

        column :friday_end_time do |user|
          user.friday_end_time&.strftime("%I:%M %p")
        end

        column :saturday_end_time do |user|
          user.saturday_end_time&.strftime("%I:%M %p")
        end

        column :sunday_end_time do |user|
          user.sunday_end_time&.strftime("%I:%M %p")
        end
      end
    end
    panel "Break Start Timings" do
      table_for @user do
        column :monday_break_start_time do |user|
          user.monday_break_start_time&.strftime("%I:%M %p")
        end

        column :tuesday_break_start_time do |user|
          user.tuesday_break_start_time&.strftime("%I:%M %p")
        end

        column :wednesday_break_start_time do |user|
          user.wednesday_break_start_time&.strftime("%I:%M %p")
        end

        column :thursday_break_start_time do |user|
          user.thursday_break_start_time&.strftime("%I:%M %p")
        end

        column :friday_break_start_time do |user|
          user.friday_break_start_time&.strftime("%I:%M %p")
        end

        column :saturday_break_start_time do |user|
          user.saturday_break_start_time&.strftime("%I:%M %p")
        end

        column :sunday_break_start_time do |user|
          user.sunday_break_start_time&.strftime("%I:%M %p")
        end
      end
    end
    panel "Break End Timings" do
      table_for @user do
        column :monday_break_end_time do |user|
          user.monday_break_end_time&.strftime("%I:%M %p")
        end

        column :tuesday_break_end_time do |user|
          user.tuesday_break_end_time&.strftime("%I:%M %p")
        end

        column :wednesday_break_end_time do |user|
          user.wednesday_break_end_time&.strftime("%I:%M %p")
        end

        column :thursday_break_end_time do |user|
          user.thursday_break_end_time&.strftime("%I:%M %p")
        end

        column :friday_break_end_time do |user|
          user.friday_break_end_time&.strftime("%I:%M %p")
        end

        column :saturday_break_end_time do |user|
          user.saturday_break_end_time&.strftime("%I:%M %p")
        end

        column :sunday_break_end_time do |user|
          user.sunday_break_end_time&.strftime("%I:%M %p")
        end
      end
    end
  end

  collection_action :import_csv, method: [:get, :post] do
    if request.post?
      require "csv"
      count = 1
      delay_count = 1
      CSV.foreach(params[:csv_file].path, encoding: "UTF-8:UTF-8", headers: true) do |row|
        Rails.logger.warn "---------------------------------------------------"
        Rails.logger.warn row.inspect
        user = User.new
        user.agree_to_terms_and_service = true
        user.role = :business
        user.scrapped_link = row["Scrapped link"]
        # user.confirmed_at = DateTime.now
        user.is_imported = true
        user.description = row["Description"]
        user.specialties = row["Specialties"]
        user.product_knowledge = row["Product knowledge"]
        user.name = row["Name"]
        user.address = row["Address"]

        results = Geocoder.search(user.address)
        address = results&.first
        user.street = address&.route || row["Street"]
        user.city = address&.city || row["City"]
        user.state = address&.state || row["State"]
        user.country = address&.country || row["Country"]
        user.zip = address&.postal_code || row["Postal Code"]
        user.latitude = address&.latitude || row["Latitude"]
        user.longitude = address&.longitude || row["Longitude"]

        user.business_number = row["Business number"]
        user.phone_number = row["Phone number"]
        user.business_website = row["Business website"]
        user.email = row["Email"]
        user.password = row["Email"]
        user.password_confirmation = row["Email"]
        user.remote_picture_url = row["Picture"]
        user.video_url = row["Video url"]
        user.twitter_url = row["Twitter"]
        user.facebook_url = row["Facebook"]
        user.instagram_url = row["Instagram"]
        user.youtube_url = row["Youtube"]
        user.linkedin_url = row["Linkedin"]
        Rails.logger.warn "####################"
        Rails.logger.warn user.remote_picture_url
        Rails.logger.warn row["Picture"]
        Rails.logger.warn "#################### Error: #{user.errors}"
        user.google_my_business = row["Map Reference"]

        user.locked_by_admin = true
        
        if user.save
          user.reload
          category = Category.find_by_name(row["Category"])
          user.license_informations.build(category_id: category.id).save!
          user.send_reset_password_instructions
        else
          Rails.logger.warn "####################"
          Rails.logger.warn "User already created."
          Rails.logger.warn "#################### Error: #{user.errors}"
        end

        if (count/5) == delay_count
          delay_count += 1
          sleep(2)
        end
        Rails.logger.warn "============ #{count} record"
        count += 1
      end
      redirect_to admin_users_path, notice: "File Imported Successfully!"
    end
  end

  member_action :remove_category, method: [:get] do
    @license_information = LicenseInformation.find_by id: params[:license_information_id]
    @user = User.find_by slug: params[:id]
    @license_information.destroy

    flash[:notice] = "LicenseInformation removed successfully!"
    redirect_to admin_user_path(@user)
  end

  member_action :change_lock_status, method: [:get] do
    @user = User.find_by slug: params[:id]
    @user.update_attribute :locked_by_admin, !@user.locked_by_admin
    flash[:notice] = "Status updated successfully!"
    redirect_to admin_user_path(@user)
  end

  member_action :restore_user, method: [:get] do
    if params[:type] == 'Restore'
      @user = User.only_deleted.find_by slug: params[:id]
      @user.update_attribute('deleted_at', nil)
      # origin_slug = @user.slug
      # if origin_slug.slug['@ARCHIVED@-']
      #   origin_slug['@ARCHIVED@-'] = ''
      #   del_user.update_attribute('slug', origin_slug) 
      #   for del_user in User.only_deleted do 
      #       origin_slug = del_user.slug
      #       if origin_slug['@ARCHIVED@-']
      #           origin_slug['@ARCHIVED@-'] = ''
      #           del_user.update_attribute('deleted_at', nil)
      #           del_user.update_attribute('slug', origin_slug) 
      #           del_user.destroy!
      #       end
      #   end
      # end
      flash[:notice] = "User restored successfully!"
    else
      @user = User.find_by slug: params[:id]
      @user.destroy!
      flash[:notice] = "User archived successfully!"
    end

    redirect_to request.referer
  end

  form do |f|
    render "google_maps_js"
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Personal Details" do
      f.input :email
      f.input :name
      f.input :address, input_html: {id: "gmaps-input-address"}
      f.input :picture
      f.input :phone_number
      f.input :business_number
      f.input :rate
      f.input :city
      f.input :state
      f.input :is_time_set
      f.input :zip
      f.input :email_permissions
      f.input :description, as: :text
      f.input :product_knowledge
      f.input :specialties
      f.input :video_url
      if resource.business?
        f.input :business_website
        f.input :business_address
      end

      div do
        h3 "Social Links"
        f.input :facebook_url
        f.input :google_my_business
        f.input :twitter_url
        f.input :instagram_url
        f.input :youtube_url
        f.input :linkedin_url
      end


      f.inputs do
        f.has_many :business_addresses,allow_destroy: true,new_record: false do |a|
          a.input :city
          a.input :zip
          a.input :url
        end
      end

      f.inputs do
        f.has_many :business_videos,allow_destroy: true,new_record: false do |a|
          a.input :video
        end
      end

      f.inputs do
        f.has_many :business_pictures,allow_destroy: true,new_record: false, class: "row" do |a|
          a.input :picture
        end
      end
      f.inputs do
        f.has_many :license_informations,allow_destroy: true,new_record: false do |a|  
          a.input :license_number
        end
      end 

      f.input :time_zone, as: :select, collection: User::TIME_ZONES, prompt: "Select Time Zone"
      f.input :locked_by_admin
      f.input :is_featured
      f.input :is_hidden
      f.input :is_verified
      f.input :is_claimed
      f.input :claim_approved
      f.input :free_of_charge
    end
    div do
      table class: "schedules" do
        thead do
          tr do
            th "Monday"
            th "Tuesday"
            th "Wednesday"
            th "Thursday"
            th "Friday"
            th "Saturday"
            th "Sunday"
          end
        end
        tbody do
          tr do
            td do
              f.input :is_monday_on, label: "On?"
            end
            td do
              f.input :is_tuesday_on, label: "On?"
            end
            td do
              f.input :is_wednesday_on, label: "On?"
            end
            td do
              f.input :is_thursday_on, label: "On?"
            end
            td do
              f.input :is_friday_on, label: "On?"
            end
            td do
              f.input :is_saturday_on, label: "On?"
            end
            td do
              f.input :is_sunday_on, label: "On?"
            end
          end

          tr do
            td f.input :monday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :tuesday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :wednesday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :thursday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :friday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :saturday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :sunday_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
          end

          tr do
            td f.input :monday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :tuesday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :wednesday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :thursday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :friday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :saturday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :sunday_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
          end

          tr do
            td f.input :monday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :tuesday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :wednesday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :thursday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :friday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :saturday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :sunday_break_start_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
          end

          tr do
            td f.input :monday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :tuesday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :wednesday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :thursday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :friday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :saturday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
            td f.input :sunday_break_end_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
          end
        end
      end
    end

    f.actions
  end
end
