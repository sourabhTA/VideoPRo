namespace :reminders do
  desc "Send email to unconfirmed users."
  task emails_to_unconfirmed_users: :environment do
    User.all_businesses.or(User.pros).in_complete.each do |user|
      if user.scrapped_link.blank?
        GenericMailer.send_reminder_email(user).deliver_now
        user.update_column "reminder_count", (user.reminder_count + 1)
      end
    end
  end
end
