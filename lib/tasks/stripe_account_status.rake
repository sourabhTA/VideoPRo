namespace :stripe_account_status do
  desc "Check account approved status"
  task update: :environment do

    User.where(stripe_account_status: "pending").each do |user|
      unless user.stripe_custom_account_id.blank?
        stripe_account_id = user.stripe_custom_account_id
        stripe_account = Stripe::Account.retrieve(stripe_account_id)
        if stripe_account.charges_enabled == true
          user.update_attribute("stripe_account_status", "approved")
        else
          user.update_attribute("stripe_account_status", "pending")
        end
      end
    end
  end
end    
