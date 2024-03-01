class CreateUserEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :user_emails do |t|
      t.integer :auto_email_id
      t.references :emailable, polymorphic: true

      t.timestamps
    end
  end
end
