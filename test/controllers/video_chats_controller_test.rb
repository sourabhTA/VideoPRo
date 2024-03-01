require "test_helper"

class VideoChatsControllerTest < ActionDispatch::IntegrationTest
  def setup
    SmsSetting.create(
      api_key: "123",
      api_secret: "456",
      phone_number: "1-555-555-5555"
    )
  end

  def params(phone_number: "1-880-555-0100", timings: "01-02-2006 02:15 PM", to_id: nil, name: "Luke", email: "recipient@example.com", tz: User::PACIFIC)
    {
      video_chat: {
        name: name,
        email: email,
        subject: "Video Chat Link",
        body: "Please click the link",
        phone_number: phone_number,
        to_id: to_id,
        timings: timings,
        time_zone: tz
      }
    }
  end

  test "it verifies the employee is part of your business" do
    other_user = create(:user)
    new_user_session
    post video_chats_path, params: params(email: nil, to_id: other_user.id)
    assert_response :unprocessable_entity
    assert_match "Receiver missing. Please enter an email address or select an employee.", response.body
  end

  test "it sets a tokbox key" do
    new_user_session

    assert_changes -> { VideoChat.count }, from: 0, to: 1 do
      post video_chats_path, params: params
    end

    assert VideoChat.last.session_id.present?
  end

  test "it sends a booking email from the business" do
    user = create(:user, time_zone: User::EASTERN)
    new_user_session(user)
    employee_email = "employee_for_chat@example.com"

    assert_changes -> { find_all_emails_to(address: employee_email).size }, from: 0, to: 1 do
      post video_chats_path, params: params(email: employee_email, tz: User::PACIFIC)
    end

    email = find_last_email_to(employee_email)
    body = email.html.to_s
    assert_equal "Video Chat Link", email.subject
    assert_match "The Video Chat is scheduled for", body
    assert_match "01-02-2006 02:15 pm</strong>, Pacific Time", body
    assert_equal url_helpers.chat_url(VideoChat.last.session_id), email.links.first
  end

  test "it sends an sms to the business" do
    user = create(:user, time_zone: User::EASTERN, phone_number: "15550102222")

    new_user_session(user)
    employee_phone = "18805550200"

    assert_changes -> { find_all_emails_to(address: user.phone_number).size }, from: 0, to: 2 do
      post video_chats_path, params: params(phone_number: employee_phone, tz: User::PACIFIC)
    end

    email = find_all_emails_to(address: user.phone_number).first
    body = email.html.to_s
    assert_equal "Test SMS", email.subject
    assert_match "#{user.name} sent you an Video Chat", body
    assert_match "begin at 01-02-2006 02:15 pm PST", body
  end

  test "it sends an sms from the business to the employee" do
    user = create(:user, time_zone: User::EASTERN)
    new_user_session(user)
    employee_phone = "18805550200"

    assert_changes -> { find_all_emails_to(address: employee_phone).size }, from: 0, to: 2 do
      post video_chats_path, params: params(phone_number: employee_phone, tz: User::PACIFIC)
    end

    email = find_all_emails_to(address: employee_phone).first
    body = email.html.to_s
    assert_equal "Test SMS", email.subject
    assert_match "#{user.name} sent you an Video Chat", body
    assert_match "begin at 01-02-2006 02:15 pm PST", body
  end

  test "it sends a reminder sms from business to the employee" do
    user = create(:user, time_zone: User::EASTERN)
    new_user_session(user)
    employee_phone = "18805550200"

    assert_changes -> { find_all_emails_to(address: employee_phone).size }, from: 0, to: 2 do
      post video_chats_path, params: params(phone_number: employee_phone, tz: User::PACIFIC)
    end

    email = find_last_email_to(employee_phone)
    body = email.html.to_s
    assert_equal "Test SMS", email.subject
    assert_match "Your In House Video Chat is scheduled to begin in 5 minutes.", body
  end

  test "schedules a 5 minute reminder to the receivers" do
    user = create(:user, time_zone: User::EASTERN)
    new_user_session(user)
    reminder_time = ActiveSupport::TimeZone[User::PACIFIC].parse("2006-01-02 14:10:00")

    Delayed::Worker.delay_jobs = true
    assert_equal 0, Delayed::Job.count

    post video_chats_path, params: params(tz: User::PACIFIC)

    jobs = Delayed::Job.all
    assert_equal 1, jobs.size
    assert_equal reminder_time, jobs.first.run_at
    Delayed::Worker.delay_jobs = false
  end
end
