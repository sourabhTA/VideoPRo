class AddMinutesAllowedToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :minutes_allowed, :integer, default: 0
  end
end
