class GenericMailer < ApplicationMailer
  def development_sms(to:, from:, text:, subject: "Test SMS")
    mail(
      to: to,
      from: from,
      subject: subject
    ) do |f|
      f.text { render plain: text }
    end
  end

  def send_reminder_email(user)
    @user = user
    mail to: user.email, subject: "Complete your Video Chat a Pro Profile"
  end

  def profile_claimed(user)
    @user = user
    mail to: AdminUser.notice_emails, subject: "Business Claimed Profile"
  end

  def send_approval_email(claim)
    @claim = claim
    mail to: @claim.email, subject: "Claim your profile"
  end

  def send_profile_unlocked_email(claim)
    @claim = claim
    @user = claim.user
    mail to: @claim.email, subject: "Your Profile is Approved"
  end

  def added_into_business(employee_params)
    @subject = "You are added as employee!"
    @employee_params = employee_params
    mail to: employee_params[:email], subject: @subject
  end

  def send_contact_us(contact)
    @contact = contact
    mail to: AdminUser.notice_emails, subject: "Some contacted on Videochatapro.com"
  end

  def user_created(user)
    @user = user
    mail to: AdminUser.notice_emails, subject: "New User Created on Videochatapro.com"
  end

  def delay_job_error(records, subject = "Error Encounter")
    @records = records
    mail to: AdminUser.notice_emails, subject: subject
  end

  def send_resume(name, address, phone, email, available, skills, job_history, file_name, file)
    @name = name
    @address = address
    @phone = phone
    @email = email
    @available = available
    @skills = skills
    @job_history = job_history

    if file != ""
      attachments[file_name] = File.read(file)
    end
    mail to: AdminUser.notice_emails, subject: "You received Job Application"
  end

  def scheduled_service_created(scheduled_service)
    @scheduled_service = scheduled_service
    mail to: scheduled_service.user.email, subject: "New In-Home Service Scheduled on Videochatapro.com"
  end

  def you_are_reviewed(review)
    @review = review
    @user = review.user
    if @user.present?
      mail to: @user.email, subject: "You received a review"
    end
  end

  def send_client_login_otp(otp)
    @otp = otp
    mail to: otp.email, subject: "Client login OTP"
  end

  def send_app_download_link(user)
    @user = user
    mail to: @user.email, subject: "Download Videochatapro App"
  end

  def send_stripe_payment_error(booking, error)
    admin_emails = AdminUser.notice_emails
    @user = booking.user
    @client = booking.client
    @error = error
    mail to: admin_emails, subject: "Stripe Payment Error"
  end

  def send_stripe_payment_exceed(booking, amount, charged_amount)
    admin_emails = AdminUser.notice_emails
    @booking = booking
    @user = booking.user
    @client = booking.client
    @amount = amount
    @charged_amount = charged_amount
    mail to: admin_emails, subject: "Stripe Payment: Full amount not deducted"
  end

  def send_email_imported_user_confirmed(user)
    admin_emails = AdminUser.notice_emails
    @user = user
    mail to: admin_emails, subject: "#{user.email} confirmed"
  end
end
