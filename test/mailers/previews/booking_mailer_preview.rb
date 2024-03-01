# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview
  def send_end_minutes_reminder_email_to_user
    BookingMailer.send_end_minutes_reminder_email_to_user(User.businesses.last)
  end

  def send_minutes_reminder_email_to_user
    BookingMailer.send_minutes_reminder_email_to_user(User.businesses.last)
  end

  def send_summary_to_client
    BookingMailer.send_summary_to_client(Booking.last)
  end

  def send_summary_to_user
    BookingMailer.send_summary_to_user(Booking.last)
  end

  def send_videochat_link_to_admins
    BookingMailer.send_videochat_link_to_admins(Booking.last)
  end

  def send_videochat_link_from_admin
    BookingMailer.send_videochat_link_from_admin(AdminVideoChat.last)
  end

  def send_videochat_link_from_business
    BookingMailer.send_videochat_link_from_business(VideoChat.last)
  end

  def send_videochat_link_to_client
    BookingMailer.send_videochat_link_to_client(Booking.last)
  end

  def send_videochat_link_to_sender
    BookingMailer.send_videochat_link_to_sender(VideoChat.last)
  end

  def send_videochat_link_to_user
    BookingMailer.send_videochat_link_to_user(Booking.last)
  end

  def send_sms_to_client
    sms_preview(:send_sms_to_client, Booking.last)
  end

  def send_sms_to_user
    sms_preview(:send_sms_to_user, Booking.last)
  end

  def send_reminder_sms_from_business
    video_chat = FactoryBot.build(:video_chat)
    sms_preview(:send_reminder_sms_from_business, video_chat, "phones")
  end

  private

  def sms_preview(method, model, to)
    to ||= model.client.phone_number
    text = SmsService.new.send(:"#{method}_body", model)
    GenericMailer.development_sms(from: SmsService.from, to: to, text: text)
  end
end
