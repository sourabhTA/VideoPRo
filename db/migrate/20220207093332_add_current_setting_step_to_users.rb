class AddCurrentSettingStepToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :current_setting_step, :string, default: ""
  end
end
