class ScheduledServicesController < ApplicationController
  include ScheduledChatsHelper

  before_action except: [:new, :create] do
    check_permissions_for(:business)
  end

  before_action :check_required_settings, only: [:index, :show], if: proc { current_user.business? }
  before_action :set_scheduled_service, only: [:show, :edit, :update]
  layout :set_layout

  def index
    @scheduled_services = current_user.scheduled_services.order(created_at: :desc)
  end

  def new
    return redirect_to new_scheduled_service_path if params[:service_type] == 'schedule'

    @exclusive_assets = ['application', 'stripe', 'map']
    @user = User.find_by(slug: params[:slug])
    @archive_user = User.readonly.only_deleted.find_by(slug: params[:slug])
    @scheduled_service = @user&.scheduled_services&.new
    if @archive_user.present?
      redirect_to error_page_302_path(trade: @archive_user.categories.pluck(:name).last&.downcase, role: @archive_user.role)
    elsif @user.blank?
      render file: "#{Rails.root}/public/404.html", layout: false, status: 404
    else 
      if AppSetting.is_render_cms
        @page = Comfy::Cms::Page.find_by(slug: "scheduled_services") if request.path.include? "scheduled_services"
        if @page
          render cms_page: @page.full_path
        else
          # redirect_to root_path
          render layout: false
        end
      else
        respond_to do |format|
          if @user.blank?
            format.all { render layout: false }
            # format.all { redirect_to root_path }
            format.js { render js: "window.location = '#{root_path}';" }
          else
            format.all { render layout: "application" }
            format.js {}
          end
        end
      end
    end
  rescue => e
    flash[:warning] = "Error: #{e.message}"
    redirect_to root_path
  end

  def create
    @scheduled_service = ScheduledService.new(scheduled_service_params)
    if verify_recaptcha(model: @scheduled_service) && @scheduled_service.save
      user = User.find(scheduled_service_params[:user_id])
      message = "Hello #{user.name} you have received a free lead. Please respond quickly to gain a new customer."

      Notification.create(title: "Lead by #{@scheduled_service.email_address}",message: message, to_id: user.id)
      fcm_push_notification(
        user.fcm_token, "Lead by #{@scheduled_service.email_address}", message, nil, true, 'user'
      ) if user.fcm_token.present?
    end

    respond_to do |format|
      if @scheduled_service.id.present?
        format.html { redirect_to show_profile_path(user), notice: "Schedule in Home Service has been booked." }
        format.js { }
      else
        format.html { redirect_to root_path, notice: "Sorry, Schedule in Home Service not booked." }
        format.js { }
      end
    end
  rescue => e
    respond_to do |format|
      format.html {
        redirect_back fallback_location: root_path, warning: "Error: #{e.message}"
      }
      format.js { }
    end
  end

  private

    def set_scheduled_service
      @scheduled_service = current_user.scheduled_services.where(id: params[:id]).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_service_params
      params.require(:scheduled_service).permit(:user_id, :property_type, :home_type, :property_age, :property_address,
        :owner_name, :your_name, :phone_number, :email_address, :scheduled_time,
        :explaination, :city, :state, :zip)
    end

    def set_layout
      "authenticated" if current_user
    end

end
