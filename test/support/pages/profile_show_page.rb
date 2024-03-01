module Pages
  class ProfileShowPage < PageObject
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def visit_page
      visit show_profile_path(user)
      self
    end

    def on_page?
      current_path == show_profile_path(user)
    end
  end
end
