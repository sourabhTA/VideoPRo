class ChangeDefaultsOfAvailabilityWeekDays < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :is_monday_on, :boolean, default: false
    change_column :users, :is_tuesday_on, :boolean, default: false
    change_column :users, :is_wednesday_on, :boolean, default: false
    change_column :users, :is_thursday_on, :boolean, default: false
    change_column :users, :is_friday_on, :boolean, default: false
    change_column :users, :is_saturday_on, :boolean, default: false
    change_column :users, :is_sunday_on, :boolean, default: false
  end

  def down
    change_column :users, :is_monday_on, :boolean, default: true
    change_column :users, :is_tuesday_on, :boolean, default: true
    change_column :users, :is_wednesday_on, :boolean, default: true
    change_column :users, :is_thursday_on, :boolean, default: true
    change_column :users, :is_friday_on, :boolean, default: true
    change_column :users, :is_saturday_on, :boolean, default: false
    change_column :users, :is_sunday_on, :boolean, default: false
  end
end
