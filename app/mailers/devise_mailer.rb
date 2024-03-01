class DeviseMailer < Devise::Mailer
  default from: "Video Chat a Pro <support@videochatapro.com>"

  def reset_password_instructions(record, token, opts={})
    if record === AdminUser.find_by(email: record.email)
      super.subject = "Password change for admin"
    elsif record.is_imported?
      super.subject = "Provide a higher level of service for shopping customers"
    else
      super
    end
  end
end
