require 'will_paginate/array'
class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception
  protect_from_forgery with: :null_session

  if (credentials = ENV["basic_auth_credentials"])
    username, password = credentials.split(":", 2)
    http_basic_authenticate_with name: username, password: password
  end

  before_action :set_raven_context
  before_action :permanent_redirect
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :users_rate,
    :home_page,
    :profile_path?,
    :search_categories,
    :search_promo_video,
    :search_promo_video_business,
    :company_path?,
    :diy_path?

  def users_rate(user)
    "#{helpers.number_to_currency(user.rate_per_minute)} per minute"
  end

  def check_permissions_for(*roles)
    unless authenticate_user!.staff_role?(*roles)
      flash[:alert] = "Sorry, you are not allowed to see this page!"
      redirect_to root_path
    end
  end

  protected

  def no_index
    @noindex = true
  end

  def no_canonical
    @nocanonical = true
  end

  def check_required_settings
    return unless user_signed_in?

    if current_user.pro?
      if current_user.profile_completed?
        redirect_to(subscriptions_path) && return
      else
        redirect_to(edit_profile_path(current_user)) && return
      end
    elsif current_user.profile_completed?
      unless subscribed?
        @error = "You need to upgrade your plan!"
        respond_to do |format|
          format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
          format.html {
            redirect_to subscriptions_path, alert: @error
          }
        end
      end
    else
      @error = "You need to add Direct Deposit"
      respond_to do |format|
        format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
        format.html {
          redirect_to edit_profile_path(current_user)
        }
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :agree_to_terms_and_service, :email_permissions, :name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone_number, :description, :email, :password,
      :picture, :rate, :category_id])
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_confirmation_path_for(resource_name, resource)
    sign_out(resource)
    new_user_session_path
  end

  def subscribed?
    current_user&.stripe_subscription_id.present?
  end

  def try_files(slugs:, default:)
    try_page = nil
    slugs.push(default).each do |s|
      try_page = Page.find_by(slug: s) if try_page.blank?
    end

    if try_page.present?
      @page = try_page
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def load_page_via_cms
    if authorize_user
      slug = (params[:controller] == "home" && params[:action] == "index") ? nil : request.path
      @role = user_role
      if AppSetting.is_render_cms
        @page = Comfy::Cms::Page.find_by(full_path: slug) || Comfy::Cms::Page.find_by(slug: request.path.split("/")[1])
        @exclusive_assets = ['application', 'stripe', 'map']
        if @page
          # if request.path == @page.full_path || request.path.split("/").count == 3
          if request.path == @page.full_path
            render cms_page: @page.full_path
          else
            @page = nil
          end
        # else
        #   @page = nil
        #   redirect_to root_path
        end
      end
    else
      render :template => 'layouts/unauthorize', status: 401
    end
  end

  def load_page_data(slug)
    @page = Page.find_by(slug: slug)

    if @page.blank?
      if params[:controller] != "home" && params[:action] == "index"
        redirect_to(root_path, notice: "Page is not available.") && return
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  private

  def authorize_user
    if ["pro_tools_to_succeed", "business_tools_to_succeed"].include? params[:slug]
      unless ( current_user && (params[:slug].include? current_user.role) )
        no_index
        return false
      end
    end
    return true
  end

  def user_role
    return "business" if request.fullpath.split("/")[1] == "business_signup"
    return "pro" if request.fullpath.split("/")[1] == "tradesman_signup"
  end

  def home_page
    @home_page ||= Page.find_by(slug: "home_page")
  end

  def profile_path?
    params[:slug] && request.path == show_profile_path(params[:slug])
  end

  def search_categories
    @search_categories ||= Category.order(:id)
  end

  def search_promo_video
    @search_promo_video ||= Video.search_promo
  end

  def search_promo_video_business
    @search_promo_video_business ||= Video.search_promo_business
  end

  def company_path?
    request.path == search_company_path(params[:trade])
  end

  def diy_path?
    request.path == search_diy_path(params[:trade])
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def permanent_redirect
    path_array = request.path.split("/")
    if request.get? && path_array[1] == "profiles" && path_array[3].nil? && params[:slug]
      redirect_to "/#{params[:slug]}", status: 301
    end
  end
end
