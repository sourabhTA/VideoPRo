class PasswordsController < Devise::PasswordsController
	after_action :email_confirm, only: [:update]
	layout proc { user.present? && user.is_imported ? "signup_steps" : "application" },only: [:edit ]

	def after_resetting_password_path_for(resource)
		if Devise.sign_in_after_reset_password
			if resource.is_imported
				GenericMailer.send_email_imported_user_confirmed(resource).deliver
				resource.pro? ? complete_profile_path : business_complete_profile_path
			else
				root_path(resource)
			end
		else
			new_session_path(resource_name)
		end
	end

	def update
		self.resource = resource_class.with_deleted.reset_password_by_token(resource_params)
		resource.recover if resource.deleted?
		yield resource if block_given?
		if resource.errors.empty?
		  resource.unlock_access! if unlockable?(resource)
		  if Devise.sign_in_after_reset_password
			flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
			set_flash_message!(:notice, flash_message)
			resource.after_database_authentication
			sign_in(resource_name, resource)
		  else
			set_flash_message!(:notice, :updated_not_active)
		  end
		  respond_with resource, location: after_resetting_password_path_for(resource)
		else
		  set_minimum_password_length
		  respond_with resource
		end
	end

	def user
		user = User.with_reset_password_token(params[:reset_password_token])
		user.update(current_setting_step: "license_information") if user.present?
		user
	end

	private
		def email_confirm
			return unless current_user
			current_user.update(confirmed_at: Time.zone.now ) if current_user.confirmed_at.nil?
		end
end
