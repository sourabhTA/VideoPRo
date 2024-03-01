require "test_helper"

class ChatsControllerDownloadVideoChatTest < ActionDispatch::IntegrationTest
  def stub_apis
    stub_s3 { stub_open_tok { yield } }
  end

  def stub_open_tok
    OpenTokClient.stub(:api_key, "/ot_api_key") do
      OpenTokClient.stub(:generate_token, "token") do
        yield if block_given?
      end
    end
  end

  test "requires login" do
    chat = create(:video_chat).reload
    get download_chat_path(chat.session_id)

    assert_redirected_to new_user_session_path
    assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "verifies the booking user id is the current user's id" do
    new_user_session
    other_user = create(:user)
    chat = create(:video_chat, creator: other_user, timings: 1.day.ago).reload

    get download_chat_path(chat.session_id)

    assert_redirected_to scheduled_chats_path
    assert_equal "You are not authorized. This incident will be reported.", flash[:alert]
  end

  test "allows business to download the chat" do
    user = create(:user, role: "business")
    new_user_session(user)
    chat = create(:video_chat, archive_id: "123", creator: user, timings: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.session_id)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "allows pro to download the chat" do
    user = create(:user, role: "pro")
    new_user_session(user)
    chat = create(:video_chat, archive_id: "123", creator: user, timings: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.session_id)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "allows employees to download the chat" do
    user = create(:user, role: "employee", business: create(:user))
    new_user_session(user)
    chat = create(:video_chat, archive_id: "123", creator: user.business, timings: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.session_id)
    end

    assert_redirected_to "http://www.example.com/ot_api_key/123/archive.mp4"
  end

  test "returns if there is no url" do
    user = new_user_session
    chat = create(:video_chat, creator: user, timings: 1.day.ago).reload

    stub_apis do
      get download_chat_path(chat.session_id)
    end

    assert_redirected_to scheduled_chats_path
    assert_equal "We could not find that archive.", flash[:alert]
  end
end
