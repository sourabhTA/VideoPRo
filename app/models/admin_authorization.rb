class AdminAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    return true if user.admin_permission.super_admin?

    case subject
    when ActiveAdmin::Page
      true
    when normalized(Blog)
      case action
      when :create
        user.admin_permission.blog_create?
      when :update
        user.admin_permission.blog_edit?
      when :destroy
        user.admin_permission.blog_delete?
      else
        true
      end
    else
      false
    end
  end
end
