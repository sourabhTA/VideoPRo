class ActiveAdmin::Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    if session[:redirect_chat_id].present?
      session_id = session.delete(:redirect_chat_id)
      chat_path(session_id)
    else
      admin_root_path
    end
  end
end
