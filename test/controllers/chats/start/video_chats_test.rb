require "test_helper"

class ChatsControllerStartVideoChatTest < ActionDispatch::IntegrationTest
  test "returns config a video chat" do
    video_chat = create(:video_chat)
    OpenTokClient.stub(:api_key, "ot_api_key") do
      OpenTokClient.stub(:generate_token, "token") do
        get start_chat_path(video_chat.session_id, format: :json)
      end
    end

    assert_response :success
    open_tok_config = {
      "sessionId" => video_chat.reload.init_session_id,
      "apiKey" => "ot_api_key",
      "token" => "token"
    }
    assert_equal open_tok_config, JSON.parse(response.body)
  end

  test "returns an error if VideoChat has no minutes available" do
    video_chat_session = create(:video_chat, seconds_left: 0).session_id

    get start_chat_path(video_chat_session, format: :json)
    assert_equal "No minutes available.", JSON.parse(response.body)["error"]
  end

  class TimesheetTest < ActionDispatch::IntegrationTest
    def create_chat
      sender = create(:user)
      chat = create(:video_chat, sender: sender)
      chat.sender = sender
      chat
    end

    test "creates a timesheet record" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.count }, from: 0, to: 1 do
        post start_clock_chat_path(chat.session_id, format: :json)
      end
    end

    test "does not modify an existing timesheet record" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.count }, from: 0, to: 1 do
        post start_clock_chat_path(chat.session_id, format: :json)
      end

      assert_no_changes -> { ChatTimesheet.last.client_start } do
        post start_clock_chat_path(chat.session_id, format: :json)
      end
    end

    test "set the client's start time" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.last&.client_start }, from: nil do
        post start_clock_chat_path(chat.session_id, format: :json)
      end
    end

    test "returns the start time for the last one to join" do
      chat = create_chat
      ChatTimesheet.set_start(chat: chat, pro: true)

      post start_clock_chat_path(chat.session_id, format: :json)
      res = {
        "start_time" => JSON.parse(chat.chat_timesheet.reload.start_time.to_json)
      }
      assert_equal res, JSON.parse(response.body)
    end

    test "set the pro's start time" do
      chat = create_chat
      new_user_session(chat.sender)

      assert_changes -> { ChatTimesheet.last&.pro_start }, from: nil do
        post start_clock_chat_path(chat.session_id, format: :json)
      end
    end
  end
end
