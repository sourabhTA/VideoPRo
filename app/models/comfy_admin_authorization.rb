module ComfyAdminAuthorization
  def authorize
    return if current_admin_user.admin_permission.super_admin?

    if params[:action] == "destroy"
      unless current_admin_user.admin_permission.cms_delete?
        flash[:danger] = "Permission denied. This incident will be reported."
        redirect_back(fallback_location: "/admin/cms") && return
      end
    end
  end
end
