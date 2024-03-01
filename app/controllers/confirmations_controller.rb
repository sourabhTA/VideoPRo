class ConfirmationsController < Devise::ConfirmationsController

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    if resource.current_setting_step != "finish"
      resource.pro? ? complete_profile_path : business_complete_profile_path
    else
      root_path
    end
  end
end
