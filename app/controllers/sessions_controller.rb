class SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    if !resource.profile_completed || resource.current_setting_step != "finish"
      resource.pro? ? complete_profile_path : business_complete_profile_path
    elsif session[:redirect_chat_id].present?
      session_id = session.delete(:redirect_chat_id)
      chat_path(session_id)
    else
      root_path
    end
  end

end
