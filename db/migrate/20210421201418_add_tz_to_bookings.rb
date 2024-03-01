class AddTzToBookings < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      alter table bookings
        alter column booking_time type timestamptz;
    SQL
  end

  def down
    execute(<<~SQL)
      alter table bookings
        alter column booking_time type timestamp;
    SQL
  end
end
