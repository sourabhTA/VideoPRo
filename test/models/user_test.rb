require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "#create_time_slots" do
    user = create(:user,
      time_zone: "Eastern Time (US & Canada)",
      monday_start_time: "15:00:00",
      monday_end_time: "05:00:00",
      is_monday_on: true,
      monday_break_start_time: "21:00:00",
      monday_break_end_time: "22:00:00").reload

    create(:booking, booking_date: "2006-01-02", user_id: user.id, booking_time: Time.new(2006, 1, 2, 20))

    hours = [
      ["12:00 AM", true],
      ["12:15 AM", true],
      ["12:30 AM", true],
      ["12:45 AM", true],

      ["01:00 AM", true],
      ["01:15 AM", true],
      ["01:30 AM", true],
      ["01:45 AM", true],

      ["12:00 PM", true],
      ["12:15 PM", true],
      ["12:30 PM", true],
      ["12:45 PM", true],

      ["01:00 PM", true],
      ["01:15 PM", true],
      ["01:30 PM", true],
      ["01:45 PM", true],

      ["02:00 PM", true],
      ["02:15 PM", true],
      ["02:30 PM", true],
      ["02:45 PM", true],

      ["03:00 PM", false],
      ["03:15 PM", false],
      ["03:30 PM", false],
      ["03:45 PM", false],

      ["04:00 PM", false],
      ["04:15 PM", false],
      ["04:30 PM", false],
      ["04:45 PM", false],

      ["05:00 PM", true], # Booking at 5 pm
      ["05:15 PM", false],
      ["05:30 PM", false],
      ["05:45 PM", false],

      ["07:00 PM", false],
      ["07:15 PM", false],
      ["07:30 PM", false],
      ["07:45 PM", false],

      ["08:00 PM", false],
      ["08:15 PM", false],
      ["08:30 PM", false],
      ["08:45 PM", false],

      ["09:00 PM", false],
      ["09:15 PM", false],
      ["09:30 PM", false],
      ["09:45 PM", false],

      ["10:00 PM", false],
      ["10:15 PM", false],
      ["10:30 PM", false],
      ["10:45 PM", false],

      ["11:00 PM", false],
      ["11:15 PM", false],
      ["11:30 PM", false],
      ["11:45 PM", false]
    ]

    dow = "monday"
    booking_date = Date.new(2006, 1, 2)
    tz = Time.find_zone("Pacific Time (US & Canada)")
    current_time = tz.parse("2006-01-02 14:45:00")

    time_slots = user.time_slots_for(dow: dow, booking_date: booking_date, tz: tz, current_time: current_time)
    assert_equal 52, time_slots.size
    assert_equal hours, time_slots.map(&:to_a)
  end

  test "#create_time_slots 15 minute buffer" do
    user = create(:user,
      time_zone: "Eastern Time (US & Canada)",
      monday_start_time: "15:00:00",
      monday_end_time: "05:00:00",
      is_monday_on: true,
      monday_break_start_time: "21:00:00",
      monday_break_end_time: "22:00:00").reload

    create(:booking, booking_date: "2006-01-02", user_id: user.id, booking_time: Time.new(2006, 1, 2, 20))

    hours = [
      ["12:00 AM", true],
      ["12:15 AM", true],
      ["12:30 AM", true],
      ["12:45 AM", true],

      ["01:00 AM", true],
      ["01:15 AM", true],
      ["01:30 AM", true],
      ["01:45 AM", true],

      ["12:00 PM", true],
      ["12:15 PM", true],
      ["12:30 PM", true],
      ["12:45 PM", true],

      ["01:00 PM", true],
      ["01:15 PM", true],
      ["01:30 PM", true],
      ["01:45 PM", true],

      ["02:00 PM", true],
      ["02:15 PM", true],
      ["02:30 PM", true],
      ["02:45 PM", true],

      ["03:00 PM", true],
      ["03:15 PM", true],
      ["03:30 PM", true],
      ["03:45 PM", true],

      ["04:00 PM", true],
      ["04:15 PM", true],
      ["04:30 PM", true],
      ["04:45 PM", true],

      ["05:00 PM", true],
      ["05:15 PM", true],
      ["05:30 PM", true],
      ["05:45 PM", true],

      ["07:00 PM", true],
      ["07:15 PM", true],
      ["07:30 PM", true],
      ["07:45 PM", false],

      ["08:00 PM", false],
      ["08:15 PM", false],
      ["08:30 PM", false],
      ["08:45 PM", false],

      ["09:00 PM", false],
      ["09:15 PM", false],
      ["09:30 PM", false],
      ["09:45 PM", false],

      ["10:00 PM", false],
      ["10:15 PM", false],
      ["10:30 PM", false],
      ["10:45 PM", false],

      ["11:00 PM", false],
      ["11:15 PM", false],
      ["11:30 PM", false],
      ["11:45 PM", false]
    ]

    dow = "monday"
    booking_date = Date.new(2006, 1, 2)
    tz = Time.find_zone("Pacific Time (US & Canada)")
    current_time = tz.parse("2006-01-02 19:16:00")

    time_slots = user.time_slots_for(dow: dow, booking_date: booking_date, tz: tz, current_time: current_time)
    assert_equal 52, time_slots.size
    assert_equal hours, time_slots.map(&:to_a)
  end
end
