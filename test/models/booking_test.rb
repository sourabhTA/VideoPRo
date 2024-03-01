require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "5 minutes before the call For timezone without transition summer->summer" do
    booking = Booking.new(booking_date: Date.new(2020, 9, 23), time_zone: "Pacific Time (US & Canada)")
    booking.set_booking_time_in_zone(date: "2020-09-23", tod: "02:00 PM")

    assert_equal Time.parse("Wed, 23 Sep 2020 13:55:00 PDT -07:00"), booking.send(:when_to_run)
  end

  test "For timezone with transition summer->standard" do
    booking = Booking.new(booking_date: Date.new(2020, 11, 23), time_zone: "Pacific Time (US & Canada)")
    booking.set_booking_time_in_zone(date: "2020-11-23", tod: "02:00 PM")

    assert_equal Time.parse("Mon, 23 Nov 2020 13:55:00 PST -08:00"), booking.send(:when_to_run)
  end

  test "For timezone without transition standard->standard" do
    booking = Booking.new(booking_date: Date.new(2020, 12, 23), time_zone: "Pacific Time (US & Canada)")
    booking.set_booking_time_in_zone(date: "2020-12-23", tod: "02:00 PM")

    assert_equal Time.parse("Wed, 23 Dec 2020 13:55:00 PST -08:00"), booking.send(:when_to_run)
  end

  test "For timezone with transition standard->summer" do
    booking = build(:booking, booking_date: Date.new(2021, 5, 23))
    booking.set_booking_time_in_zone(date: "2021-05-23", tod: "02:00 PM")
    booking.save
    booking.reload

    assert_equal Time.parse("Sun, 23 May 2021 13:55:00 PDT -07:00"), booking.send(:when_to_run)
  end

  test "early link when 1 minute before now" do
    booking = Booking.new(time_zone: "Pacific Time (US & Canada)")
    booking.set_booking_time_in_zone(date: "2006-01-02", tod: "02:15 PM")

    current_time = Time.parse("Mon, 2 Jan 2006 14:14:00 PST -08:00")
    assert booking.early_link?(current_time)
  end

  test "expired link when 1 hour ago" do
    booking = Booking.new(time_zone: "Pacific Time (US & Canada)")
    booking.set_booking_time_in_zone(date: "2006-01-02", tod: "02:15 PM")

    current_time = Time.parse("Mon, 2 Jan 2006 15:16:00 PST -08:00")
    assert booking.expired_link?(current_time)
  end
end
