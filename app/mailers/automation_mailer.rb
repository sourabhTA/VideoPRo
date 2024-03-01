class AutomationMailer < ApplicationMailer
  def send_email(user, auto_email)
    @user = user
    @auto_email = auto_email
    mail to: @user.email, subject: @auto_email.subject
  end

  def send_email_plan_downgrade(user, event)
    @user = user
    @event = event
    mail to: @user.email, subject: "Plan downgrade cause of failed monthly subscription"
  end
end
