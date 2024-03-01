class AddReminderCountToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reminder_count, :integer, default: 0
  end
end
