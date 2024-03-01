# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[5.1]
  def self.up
    drop_table :users
    create_table :users do |t|
      ## Database authenticatable
      t.string  :email,              null: false, default: ""
      t.string  :encrypted_password, null: false, default: ""
      t.string  :name
      t.string  :phone_number
      t.integer :role, null: false
      t.string  :city
      t.string  :state
      t.string  :zip
      t.boolean :agree_to_terms_and_service, null: false
      t.string  :category_id
      t.string  :picture
      t.integer :rate
      t.string  :license_type
      t.text    :description
      t.string  :availability
      t.string  :time_zone
      t.string  :business_website
      t.boolean :locked_by_admin, default: true

      t.boolean :is_monday_on, default: true
      t.boolean :is_tuesday_on, default: true
      t.boolean :is_wednesday_on, default: true
      t.boolean :is_thursday_on, default: true
      t.boolean :is_friday_on, default: true
      t.boolean :is_saturday_on, default: false
      t.boolean :is_sunday_on, default: false
      t.time :monday_start_time, default: '9:00 am'
      t.time :monday_end_time, default: '6:00 pm'
      t.time :tuesday_start_time, default: '9:00 am'
      t.time :tuesday_end_time, default: '6:00 pm'
      t.time :wednesday_start_time, default: '9:00 am'
      t.time :wednesday_end_time, default: '6:00 pm'
      t.time :thursday_start_time, default: '9:00 am'
      t.time :thursday_end_time, default: '6:00 pm'
      t.time :friday_start_time, default: '9:00 am'
      t.time :friday_end_time, default: '6:00 pm'
      t.time :saturday_start_time, default: '9:00 am'
      t.time :saturday_end_time, default: '6:00 pm'
      t.time :sunday_start_time, default: '9:00 am'
      t.time :sunday_end_time, default: '6:00 pm'
      t.time :monday_break_start_time, default: '1:00 pm'
      t.time :monday_break_end_time, default: '2:00 pm'
      t.time :tuesday_break_start_time, default: '1:00 pm'
      t.time :tuesday_break_end_time, default: '2:00 pm'
      t.time :wednesday_break_start_time, default: '1:00 pm'
      t.time :wednesday_break_end_time, default: '2:00 pm'
      t.time :thursday_break_start_time, default: '1:00 pm'
      t.time :thursday_break_end_time, default: '2:00 pm'
      t.time :friday_break_start_time, default: '1:00 pm'
      t.time :friday_break_end_time, default: '2:00 pm'
      t.time :saturday_break_start_time, default: '1:00 pm'
      t.time :saturday_break_end_time, default: '2:00 pm'
      t.time :sunday_break_start_time, default: '1:00 pm'
      t.time :sunday_break_end_time, default: '2:00 pm'





      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      # Uncomment below if timestamps were not included in your original model.
      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
