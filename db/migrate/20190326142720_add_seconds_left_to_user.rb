class AddSecondsLeftToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :seconds_left, :integer, default: 0
  end
end
