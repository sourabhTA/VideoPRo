module SearchHelper
  def home_page?
    controller_name == "home" && action_name == "index"
  end

  def search_page?
    controller_name == "search" && action_name == "index"
  end

  def diy_page?
    params[:help_with].present? && params[:help_with] == "pros"
  end

  def company_page?
    params[:help_with].present? && params[:help_with] == "businesses"
  end

  def schedule_label(user)
    if user.role == "business"
      user.user_category == 'Mechanics' ? "Request a Call Back" : "Schedule In Home Service"
    else
      "Schedule In Home Service"
    end
  end

end
