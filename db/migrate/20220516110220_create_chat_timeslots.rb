class CreateChatTimeslots < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_timeslots do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :time_used
      t.references :chat_timesheet, foreign_key: true

      t.timestamps
    end
  end
end
