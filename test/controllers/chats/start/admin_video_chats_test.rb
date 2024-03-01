require "test_helper"

class ChatsControllerStartAdminVideoChatTest < ActionDispatch::IntegrationTest
  test "returns config an admin video chat" do
    video_chat = create(:admin_video_chat).reload
    OpenTokClient.stub(:api_key, "ot_api_key") do
      OpenTokClient.stub(:generate_token, "token") do
        get start_chat_path(video_chat.client_token, format: :json)
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

  class TimesheetTest < ActionDispatch::IntegrationTest
    def create_chat
      create(:admin_video_chat).reload
    end

    test "creates a timesheet record" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.count }, from: 0, to: 1 do
        post start_clock_chat_path(chat.client_token, format: :json)
      end
    end

    test "does not modify an existing timesheet record" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.count }, from: 0, to: 1 do
        post start_clock_chat_path(chat.client_token, format: :json)
      end

      assert_no_changes -> { ChatTimesheet.last.client_start } do
        post start_clock_chat_path(chat.client_token, format: :json)
      end
    end

    test "set the client's start time" do
      chat = create_chat

      assert_changes -> { ChatTimesheet.last&.client_start }, from: nil do
        post start_clock_chat_path(chat.client_token, format: :json)
      end
    end

    test "returns the start time for the last one to join" do
      chat = create_chat
      ChatTimesheet.set_start(chat: chat, pro: true)

      OpenTokClient.stub(:api_key, "ot_api_key") do
        OpenTokClient.stub(:generate_token, "token") do
          post start_clock_chat_path(chat.client_token, format: :json)
        end
      end

      res = {
        "start_time" => JSON.parse(chat.chat_timesheet.reload.start_time.to_json)
      }
      assert_equal res, JSON.parse(response.body)
    end

    test "set the pro's start time" do
      chat = create_chat
      new_admin_user_session

      assert_changes -> { ChatTimesheet.last&.pro_start }, from: nil do
        post start_clock_chat_path(chat.professional_token, format: :json)
      end
    end
  end
end
