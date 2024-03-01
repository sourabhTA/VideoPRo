class AddLastSentToUserEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :user_emails, :last_sent, :date
  end
end
