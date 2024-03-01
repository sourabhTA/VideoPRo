class AddForAllToAutoEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_emails, :for_all, :boolean, default: false
  end
end
