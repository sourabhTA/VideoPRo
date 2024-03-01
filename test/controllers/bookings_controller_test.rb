require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    SmsSetting.create(
      api_key: "123",
      api_secret: "456",
      phone_number: "1-555-555-5555"
    )
  end

  def params(user:, client_email: "client@example.com", tz: "Pacific Time (US & Canada)")
    {
      client: {
        first_name: "Luke",
        last_name: "Walker",
        email: client_email,
        phone_number: "1-800-555-0100",
        booking_attributes: {
          user_id: user.id,
          is_booking_fake: "true",
          stripeToken: "",
          issue: "Drain clogged",
          city: "Fifty-Six",
          state: "AR",
          agree_with_terms_and_conditions: true,
          time_zone: tz,
          booking_date: "1/2/2006",
          booking_time: "02:15 PM"
        }
      }
    }
  end

  test "create creates a booking" do
    user = create(:user)

    from = Booking.count
    assert_changes -> { Booking.count }, from: from, to: from + 1 do
      post bookings_path, params: params(user: user)
    end
  end

  test "returns a thankyou url" do
    user = create(:user)

    post bookings_path, params: params(user: user)
    assert_equal JSON.parse(response.body), {"redirect_url" => thankyou_booking_url(Booking.last.slug)}
  end

  test "create creates a client" do
    user = create(:user)

    from = Client.count
    assert_changes -> { Client.count }, from: from, to: from + 1 do
      post bookings_path, params: params(user: user)
    end
  end

  test "schedules a 5 minute reminder to the client and user" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")
    reminder_time = ActiveSupport::TimeZone["Pacific Time (US & Canada)"].parse("2006-01-02 14:10:00")

    Delayed::Worker.delay_jobs = true
    assert_equal 0, Delayed::Job.count

    post bookings_path, params: params(user: user)

    jobs = Delayed::Job.all
    assert_equal 1, jobs.size
    assert_equal reminder_time, jobs.first.run_at
    Delayed::Worker.delay_jobs = false
  end

  test "sends a video chat link email to the user" do
    user = create(:user, time_zone: "Central Time (US & Canada)")

    from = find_all_emails_to(address: user.email).size
    assert_changes -> { find_all_emails_to(address: user.email).size }, from: from, to: from + 1 do
      post bookings_path, params: params(user: user)
    end

    email = find_last_email_to(user.email)
    body = email.html.to_s
    assert_match "Booking Date: 01-02-2006", body
    assert_match "Booking Time: 04:15 PM CST", body
    assert_equal email.links[1], url_helpers.chat_url(Booking.last.professional_token)
  end

  test "thank you page" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")
    post bookings_path, params: params(user: user)
    get thankyou_booking_path(Booking.last)
    body = response.body
    assert_match "Date: 01/02/2006", body
    assert_match "Time: 02:15 PM", body
  end

  test "sends a video chat link email to the client" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")
    client_email = "client@example.com"

    assert_changes -> { find_all_emails_to(address: client_email).size }, from: 0, to: 1 do
      post bookings_path, params: params(user: user, client_email: client_email)
    end

    email = find_last_email_to(client_email)
    body = email.html.to_s
    assert_match "Booking Date: 01-02-2006", body
    assert_match "Booking Time: 02:15 PM", body
    assert_equal email.links[1], url_helpers.chat_url(Booking.last.client_token)
  end

  test "sends a video chat link email to the admin" do
    admin_user = create(:super_admin_user, email: "admin@example.com")
    user = create(:user, time_zone: "Pacific Time (US & Canada)")

    from = find_all_emails_to(address: admin_user.email).size
    assert_changes -> { find_all_emails_to(address: admin_user.email).size }, from: from, to: from + 1 do
      post bookings_path, params: params(user: user)
    end

    email = find_last_email_to(admin_user.email)
    body = email.html.to_s
    assert_equal email.subject, "Pro is booked!"
    assert_match "01-02-2006", body
    assert_match "05:15 PM EST", body # Admin views Eastern TZ (because the don't have a tz in the database)
    assert_equal email.links[1], url_helpers.chat_url(Booking.last.professional_token)
  end

  test "sends a video chat link sms to the client" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")

    sms_address = "18005550100"
    booking_sms = -> {
      find_all_emails_to(address: sms_address).select { |e|
        e.body.include?("Thank you for scheduling with Video Chat a Pro")
      }.to_a
    }

    assert_changes -> { booking_sms.call.size }, from: 0, to: 1 do
      post bookings_path, params: params(user: user)
    end

    email = booking_sms.call.first
    body = email.html.text
    assert_equal "Test SMS", email.subject
    assert_match "Thank you for scheduling with Video Chat a Pro", body
    assert_match "You will receive a reminder 5 minutes before your video chat", body
    assert_match "at 01-02-2006", body
    assert_match "and 02:15 PM", body
  end

  test "sends a video chat link sms to the user" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")

    sms_address = user.phone_number.remove(/\D/)
    booking_sms = -> {
      find_all_emails_to(address: sms_address).select { |e|
        e.body.include?("You are booked for a Video Chat")
      }.to_a
    }

    assert_changes -> { booking_sms.call.size }, from: 0, to: 1 do
      post bookings_path, params: params(user: user)
    end

    email = booking_sms.call.first
    body = email.html.text
    assert_equal "Test SMS", email.subject
    assert_match "You are booked for a Video Chat", body
    assert_match "at 01-02-2006", body
    assert_match "and 02:15 PM", body
  end

  test "create sets the timezone to the client's choice" do
    user = create(:user, time_zone: "Pacific Time (US & Canada)")
    post bookings_path, params: params(user: user, tz: "Eastern Time (US & Canada)")
    assert_equal "Eastern Time (US & Canada)", Booking.last.time_zone
  end
end
