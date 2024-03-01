class AddAutomationToUserEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :user_emails, :automation, :boolean
  end
end
