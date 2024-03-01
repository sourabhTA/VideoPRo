module Pages
  class NewUserSessionPage < PageObject
    def visit_page
      visit new_user_session_path
      self
    end

    def on_page?
      has_selector? "h1", text: "Sign in"
    end

    def fill_in_email(email)
      fill_in "user_email", with: email
      self
    end

    def fill_in_password(password)
      fill_in :user_password, with: password
      self
    end

    def press_sign_in
      within "form" do
        click_on "Login"
      end
      self
    end

    def has_credential_error?
      has_error?("Invalid Email or password")
    end

    def has_must_login_error?
      has_error?("You need to sign in or sign up before continuing.")
    end

    def has_must_chat_warning?
      has_warning?("You must login to join this video chat.")
    end
  end
end
