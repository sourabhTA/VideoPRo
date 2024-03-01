class AddBreakTimingsToPros < ActiveRecord::Migration[5.1]
  def change
    add_column :pros, :monday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :monday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :tuesday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :tuesday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :wednesday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :wednesday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :thursday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :thursday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :friday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :friday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :saturday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :saturday_break_end_time, :time, default: '2:00 pm'
    add_column :pros, :sunday_break_start_time, :time, default: '1:00 pm'
    add_column :pros, :sunday_break_end_time, :time, default: '2:00 pm'
  end
end
