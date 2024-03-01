require "digest/sha2"

class BookingMailer < ApplicationMailer
  layout "booking_mailer"

  def send_minutes_reminder_email_to_user(business_user)
    @reciever = business_user
    @subject = "Your minutes to video chat are about to end"
  end

  def send_end_minutes_reminder_email_to_user(business_user)
    @reciever = business_user
    @subject = "Your minutes to video chat has ended"
  end

  def send_videochat_link_to_user(booking)
    @booking = booking
    receivers = booking.user.business? ? booking.user.all_business_users.notification_allowed.map(&:email) : [booking.user.email]
    mail to: receivers, subject: "You Have a New Customer"
  end

  def send_videochat_link_to_client(booking)
    @booking = booking
    mail to: booking.client.email, subject: "#{booking.user} is Booked!"
  end

  def send_summary_to_client(booking)
    @reciever = booking.client
    @user = booking.user
    @booking = booking
    @subject = "Video Chat a Pro Receipt and Review"

    mail to: @reciever.email, subject: @subject
  end

  def send_summary_to_user(booking)
    @booking = booking
    @subject = "Video Chat Summary"
    @receivers = [booking.user.email]
    mail to: @receivers, subject: @subject
  end

  def send_videochat_link_from_admin(admin_video_chat)
    @reciever = admin_video_chat.email
    @admin_video_chat = admin_video_chat
    @subject = admin_video_chat.subject
    @body = admin_video_chat.body

    mail to: @reciever, subject: @subject
  end

  def send_videochat_link_from_business(video_chat)
    @video_chat = video_chat
    mail to: video_chat.email_receivers, subject: video_chat.subject
  end

  def send_videochat_link_to_sender(video_chat)
    @reciever = video_chat.user.email
    @video_chat = video_chat
    @subject = video_chat.subject
    @body = video_chat.body
    @name = video_chat.user

    mail to: @reciever, subject: @subject
  end

  def send_videochat_link_to_admins(booking)
    @booking = booking
    mail to: AdminUser.notice_emails, subject: "Pro is booked!"
  end

  def send_email_to_admin_refund_payment(booking)
    @booking = booking
    @user = User.readonly.with_deleted.find_by(id: booking.user_id)
    mail to: AdminUser.notice_emails, subject: "Refund for No Show User"
  end

  def send_email_to_client_refund_payment(booking)
    @booking = booking
    @user = User.readonly.with_deleted.find_by(id: booking.user_id)
    mail to: @booking.client.email, subject: "Refund for No Show User"
  end

  helper_method :booking, :video_chat, :admin_timezone

  private

  attr_reader :booking, :video_chat

  def admin_timezone
    User::EASTERN
  end
end
