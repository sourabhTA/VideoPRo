require "application_system_test_case"

class VideoChatsTest < ApplicationSystemTestCase
  let(:page) { Pages::VideoChatNewPage.new }
  let(:index_page) { Pages::VideoChatIndexPage.new }
  let(:sign_in_page) { Pages::NewUserSessionPage.new }

  def setup
    SmsSetting.create(
      api_key: "123",
      api_secret: "456",
      phone_number: "1-555-555-5555"
    )
  end

  test "it creates a video chat" do
    user = new_user_session
    index_page.visit_page
    assert index_page.on_page?

    index_page.press_send_video_chat
    assert page.on_page?

    page
      .fill_in_chat_time("01-02-2006 11:45 AM")
      .select_time_zone(User::PACIFIC)
      .fill_in_email("employee@example.com")
      .fill_in_name("Han")
      .press_send

    assert index_page.on_page?
    assert index_page.has_created_notice?
    assert_equal index_page.video_chats_table, [{
      "Email" => "employee@example.com and #{user.email}",
      "Name" => user.name,
      "Phone Number" => "",
      "Timings" => "01-02-2006 11:45 am PST",
      "Link" => "Expired"
    }]
  end

  test "it requires you to be logged in" do
    page.visit_page
    assert sign_in_page.on_page?
    assert sign_in_page.has_must_login_error?
  end

  test "it requires an employee or email" do
    new_user_session
    index_page.visit_page
    assert index_page.on_page?

    index_page.press_send_video_chat
    assert page.on_page?

    page
      .fill_in_chat_time("01-02-2006 11:45 AM")
      .select_time_zone(User::PACIFIC)
      .fill_in_email("")
      .fill_in_name("Han")
      .press_send

    assert index_page.on_page?
    assert index_page.has_missing_recipient_error?
  end

  test "it sets the timing to the recipient's time zone" do
    user = create(:user, time_zone: User::EASTERN)
    new_user_session(user)

    index_page.visit_page
      .press_send_video_chat

    page
      .fill_in_chat_time("01-02-2006 11:45 AM")
      .select_time_zone(User::PACIFIC)
      .fill_in_email("employee@example.com")
      .fill_in_name("Han")
      .press_send

    assert_equal index_page.video_chats_table, [{
      "Email" => "employee@example.com and #{user.email}",
      "Name" => user.name,
      "Phone Number" => "",
      "Timings" => "01-02-2006 11:45 am PST",
      "Link" => "Expired"
    }]
  end
end
