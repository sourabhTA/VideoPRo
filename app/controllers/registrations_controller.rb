class RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: [:show, :edit, :destroy]
  before_action :validate_role, only: :create

  def validate_role
    unless %w[pro business].include? params[:user][:role]
      flash[:error] = 'Please select correct Role'
      redirect_to signup_path
    end
  end

  def create
    if Rails.env.development?
      super
    elsif verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = 'There was an error with the recaptcha code below. Please re-enter the code.'
      flash.delete :recaptcha_error
      render :new
    end
  end

  private
    def after_sign_up_path_for(resource)
      resource.pro? ? complete_profile_path : business_complete_profile_path
      # edit_profile_path(resource)
    end

    def set_user
      @user = User.find_by slug: params[:slug]
    end
end
