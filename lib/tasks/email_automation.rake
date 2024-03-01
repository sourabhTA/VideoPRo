namespace :email_automation do
  desc "Send automation emails."
  task start: :environment do
    all_users = User.all.have_tokens
    all_customers = Client.all.have_tokens

    AutoEmail.all.each do |auto_email|
      if auto_email.for_all
        case auto_email.role
        when "pro" # all pros without categories
          all_users.pros.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).each do |pro|
            send_email(pro, auto_email)
          end
        when "business" # all business without categories
          all_users.businesses.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).each do |business|
            send_email(business, auto_email)
          end
        when "customer" # all customers
          all_customers.email_subscribed.each do |customer|
            send_email(customer, auto_email)
          end
        else
          # all users without categories and without role
          all_users.email_subscribed.send(auto_email.segment.downcase.parameterize.underscore.to_sym).each do |pro|
            send_email(pro, auto_email)
          end
          # all customers
          all_customers.email_subscribed.each do |customer|
            send_email(customer, auto_email)
          end
        end
      else
        case auto_email.role
        when "pro"
          all_users.pros.email_subscribed.trades(auto_email.category_id).send(auto_email.segment.downcase.parameterize.underscore.to_sym).each do |pro|
            send_email(pro, auto_email)
          end
        when "business"
          all_users.businesses.email_subscribed.trades(auto_email.category_id).send(auto_email.segment.downcase.parameterize.underscore.to_sym).each do |business|
            send_email(business, auto_email)
          end
        when "customer"
          all_customers.email_subscribed.each do |customer|
            send_email(customer, auto_email)
          end
        end
      end
    end
  end

  def send_email(user, auto_email)
    if auto_email.automation
      user_email = user.user_emails.every_time.where(auto_email_id: auto_email.id).order(last_sent: :desc).first
      puts "######################################"
      puts (user.created_at + auto_email.number_of_days.to_i.days).to_date == DateTime.current.to_date

      if user_email.nil?
        if (user.created_at + auto_email.number_of_days.to_i.days).to_date == DateTime.current.to_date
          user.user_emails.create(auto_email_id: auto_email.id, last_sent: DateTime.current.to_date, automation: true)
          AutomationMailer.send_email(user, auto_email).deliver_now
        end
      elsif (user_email.last_sent + auto_email.number_of_days.to_i.days).to_date == DateTime.current.to_date
        user.user_emails.create(auto_email_id: auto_email.id, last_sent: DateTime.current.to_date, automation: true)
        AutomationMailer.send_email(user, auto_email).deliver_now
      end
    else
      user_email = user.user_emails.one_time.where(auto_email_id: auto_email.id).first
      if user_email.nil?
        if auto_email.number_of_days.to_i == 0
          user.user_emails.create(auto_email_id: auto_email.id, last_sent: DateTime.current.to_date, automation: false)
          AutomationMailer.send_email(user, auto_email).deliver_now
        elsif (user.created_at + auto_email.number_of_days.to_i.days).to_date == DateTime.current.to_date
          user.user_emails.create(auto_email_id: auto_email.id, last_sent: DateTime.current.to_date, automation: false)
          AutomationMailer.send_email(user, auto_email).deliver_now
        end
      end
    end
  rescue => e
    Rails.logger.warn "##############################################################################"
    Rails.logger.warn e.inspect
  end
end

# UserEmail.all.delete_all
# User.all.update_all({created_at: 1.day.ago})
# Client.all.update_all({created_at: 1.day.ago})
