module PageSupport
  def new_user_session(user = create(:user))
    Pages::NewUserSessionPage.new
      .visit_page
      .fill_in_email(user.email)
      .fill_in_password(user.password)
      .press_sign_in

    assert current_path != new_user_session_path
    user
  end
end
