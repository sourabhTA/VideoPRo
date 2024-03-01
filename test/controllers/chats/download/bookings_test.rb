require "test_helper"

class ChatsControllerDownloadBookingsTest < ActionDispatch::IntegrationTest
  def stub_apis
    stub_s3 { stub_open_tok { yield } }
  end

  test "requires login" do
    chat = create(:booking, booking_time: 1.day.ago).reload
    get download_chat_path(chat.professional_token)

    assert_redirected_to new_user_session_path
    assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "verifies the booking user id is the current user's id" do
    new_user_session
    other_user = create(:user)
    chat = create(:booking, user: other_user, booking_time: 1.day.ago).reload

    get download_chat_path(chat.professional_token)

    assert_redirected_to scheduled_chats_path
    assert_equal "You are not authorized. This incident will be reported.", flash[:alert]
  end

  test "allows business to download the chat" do
    user = create(:user, role: "business")
    new_user_session(user)
    chat = create(:booking, archive_id: "123", user: user, booking_time: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.professional_token)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "allows pro to download the chat" do
    user = create(:user, role: "pro")
    new_user_session(user)
    chat = create(:booking, archive_id: "123", user: user, booking_time: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.professional_token)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "allows employees to download the chat" do
    user = create(:user, role: "employee", business: create(:user))
    new_user_session(user)
    chat = create(:booking, archive_id: "123", user: user.business, booking_time: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.professional_token)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "returns if there is no url" do
    user = new_user_session
    chat = create(:booking, user: user, booking_time: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.professional_token)
    end

    assert_redirected_to scheduled_chats_path
    assert_equal "We could not find that archive.", flash[:alert]
  end
end
