class ProfilesController < AuthenticatedController
  skip_before_action :authenticate_user!, only: %i[show auto_login claim_business user_reviews error_page_302]
  layout "application", only: [:show, :claim_business, :user_reviews ]

  before_action :no_index, except: [:show]
  before_action :no_index, only: [:show], if: :user_pending_validation?

  def tools_to_succeed
    default_slug = "tools_to_succeed"
    slug = "#{current_user.role}_#{default_slug}"
    try_files(slugs: [slug], default: default_slug)
  end

  def auto_login
    @user = User.find_by token: params[:token]
    sign_in(@user, scope: :user)
    flash[:notice] = "Signed in successfully, please update your information"
    redirect_to edit_profile_path(@user)
  end

  def claim_business
    @user = User.find_by slug: params[:slug]
    if @user.blank?
      flash[:alert] = "Profile doesn't exist."
      redirect_to root_path
      return
    end

    if request.post?
      if verify_recaptcha
        if user_params[:email] == @user.email && Phonelib.parse(user_params[:phone_number]).e164 == Phonelib.parse(@user.phone_number).e164
          @user.send_reset_password_instructions
          redirect_to(root_path, notice: "We sent you an email to finish claiming your business profile.") && return
        else
          render("/profiles/claim_business") && return
        end

      else
        render("/profiles/claim_business") && return
      end
    elsif @user.confirmed?
      redirect_to(subscriptions_path, notice: "This profile already claimed, please subscribed.") && return
    end
  end

  def error_page_302
    @trade = params[:trade]
    @role = params[:role]
    render layout: false
  end

  def complete_profile
    @user = current_user
    @bank_account = BankAccount.new
    render layout: "signup_steps"
  end

  def business_complete_profile
    @user = current_user
    @bank_account = BankAccount.new
    @employee ||= User.new
    @employees ||= current_user&.employees&.in_order if current_user&.employees.present?
    render layout: "signup_steps"
  end


  def edit
    @user = current_user
    redirect_to root_path if @user.scrapped?
  end

  def availability
    @user = current_user
  end

  def show
    @user ||= User.find_by slug: params[:slug]
    @archive_user = User.readonly.with_deleted.find_by(slug: params[:slug])
    @profile_page = true

    if @user.present?
      @exclusive_assets = ['application', 'stripe']
      @map_json = @user.bookings.booking_completed.where("latitude IS NOT NULL AND longitude IS NOT NULL").map { |b| { "lat": b.latitude, "lng": b.longitude } }
      @map_json << { "lat": @user.latitude, "lng": @user.longitude } if @user.latitude && @user.longitude

      redirect_to root_path if @user.scrapped?
      @reviews = @user.reviews.to_a
      @avg_rating = if @reviews.blank?
      else
        @user.reviews.average(:rating).round(2)
      end
    else
      if @archive_user.present?
        @category = @archive_user.categories.pluck(:name).last&.downcase
        # render layout: "extra"
        redirect_to error_page_302_path(trade: @category, role: @archive_user.role)
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status: 404
      end
    end
  end

  def update
    @user = current_user
    if user_params[:business_website] && (user_params[:business_website].include? "videochatapro.com")
      params[:user][:business_website] = @user.business_website
    end
    # IF they've left the password field blank,
    # AND the devise update_without_password method returns true
    # OR IF a full update of user (including password and password_confirmation) returns true
    # THEN re-sign them in to flush their session, and redirect them back to their dashboard, and send a success message.
    # ELSE re-present the edit form they were just on (there's a handy catcher
    # in the edit view script to render the form errors, you can find them on
    # @user.errors)
    #
    if user_params[:password] == user_params[:password_confirmation]
      if (user_params[:password].blank? && @user.update_without_password(user_params)) || @user.update_attributes(user_params)
        @user.update_column(:profile_completed, true)

        if user_params[:picture].present?
          respond_to do |format|
            format.json { render json: {} }
            format.html { render :crop }
          end
        else
          bypass_sign_in(@user)
          respond_to do |format|
            format.js { }
            format.html {
              redirect_back fallback_location: root_path, notice: "Your profile changes have been saved."
            }
          end
        end
      else
        @error = "Something went wrong"
        respond_to do |format|
          format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
          format.html {
            render "edit"
          }
        end
      end
    else
      @error = "confirmation doesn't match Password"
      respond_to do |format|
        format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
        format.html {
          @user.errors.add(:password, @error)
          render "edit"
        }
      end
    end
  rescue => e
    @error = e.message
    respond_to do |format|
      format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
      format.html {
        render "edit"
      }
    end
  end

  def destroy
    begin
      current_user.destroy!
      flash[:notice] = "Profile deleted successfully."
      redirect_to root_path
    rescue => e
      flash[:alert] = "Something went wrong."
      redirect_to root_path
    end
  end

  def getTabData
    @user = current_user
    @bank_account = BankAccount.new
    @employee ||= User.new
    @employees ||= current_user&.employees&.in_order if current_user&.employees.present?
    @plans = current_user.pro? ? Plan.active.free_pro : Plan&.active.not_free_pro&.in_order
    render :partial => "partials/signup_steps/#{params[:tabName]}"
  rescue => e
    render json: { error: e.message }, status: 400
  end

  def skip_step
    if params[:current_step]
      if current_user.update(current_setting_step: params[:current_step])
        render json: { message: params[:current_step] }
      else
        render json: { message: "Not Updated" }
      end
    else
      render json: { message: "Required Step" }
    end
  rescue => e
    render json: { error: e.message }, status: 400
  end

  def email_download_link
    GenericMailer.send_app_download_link(current_user).deliver_now
    SmsService.send_sms_app_link_to_user(current_user.phone_number) if current_user.phone_number.present?
  rescue => e
    @error = e.message
    render json: { error: @error }, status: 400
  end

  def user_reviews
    @user ||= User.find_by slug: params[:slug]
    @archive_user = User.readonly.only_deleted.find_by(slug: params[:slug])
    @exclusive_assets = ['application', 'stripe', 'map']
    
    if @user.present?
      @reviews = @user.reviews
    else 
      if @archive_user.present?
        redirect_to error_page_302_path(trade: @archive_user.categories.pluck(:name).last&.downcase, role: @archive_user.role)
      else
        render file: "#{Rails.root}/public/404.html", layout: false, status: 404
      end
    end
  rescue => e
    Rails.logger.info "Error: #{ e.message }"
  end

  private

    def user_from_slug
      @user ||= User.with_slugs.where(slug: params[:slug]).first
    end

    def user_pending_validation?
      user_from_slug&.pending_stripe_validation?
    end

    def user_params
      accessible = [:video_url_description, :current_setting_step, :name, :business_number, :phone_number, :email, :password, :password_confirmation, :picture, :rate, :category_id, :business_address,
        :license_type, :description, :city, :state, :zip, :availability, :business_website, :time_zone, :email_permissions,
        :is_monday_on, :is_tuesday_on, :is_wednesday_on, :is_thursday_on, :is_friday_on, :is_saturday_on, :is_time_set,
        :is_sunday_on, :monday_start_time, :monday_end_time, :tuesday_start_time, :tuesday_end_time, :crop_x, :crop_y, :crop_w, :crop_h,
        :wednesday_start_time, :wednesday_end_time, :thursday_start_time, :thursday_end_time, :friday_start_time,
        :friday_end_time, :saturday_start_time, :saturday_end_time, :sunday_start_time, :sunday_end_time, :is_van_paid,
        :monday_break_start_time, :monday_break_end_time, :tuesday_break_start_time, :tuesday_break_end_time, :free_of_charge,
        :wednesday_break_start_time, :wednesday_break_end_time, :thursday_break_start_time, :thursday_break_end_time,
        :friday_break_start_time, :friday_break_end_time, :saturday_break_start_time, :saturday_break_end_time,
        :sunday_break_start_time, :sunday_break_end_time, :address, :facebook_url, :twitter_url, :instagram_url, :youtube_url,
        :linkedin_url, :video_url, :product_knowledge, :specialties, :google_my_business, :claim_approved, :is_claimed,
        license_informations_attributes: [:id, :user_id, :category_id, :license_number, :state_issued, :expiration_date, :_destroy],
        business_addresses_attributes: [:id, :user_id, :city, :zip, :price, :url, :_destroy],
        business_pictures_attributes: [:id, :user_id, :picture, :alt, :description, :_destroy],
        business_videos_attributes: [:id, :user_id, :video, :alt, :description, :_destroy]]

      params.require(:user).permit(accessible)
    end
end
