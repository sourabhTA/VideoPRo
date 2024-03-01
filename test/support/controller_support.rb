module ControllerSupport
  def new_user_session(user = create(:user))
    post user_session_path, params: {user: {email: user.email, password: user.password}}
    user
  end

  def new_admin_user_session(user = create(:admin_user))
    post admin_user_session_path, params: {admin_user: {email: user.email, password: user.password}}
    user
  end
end
