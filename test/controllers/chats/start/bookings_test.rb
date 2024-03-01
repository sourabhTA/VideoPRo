require "test_helper"

class ChatsControllerStartBookingsTest < ActionDispatch::IntegrationTest
  test "returns config for a booking for the client" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload

    OpenTokClient.stub(:api_key, "ot_api_key") do
      OpenTokClient.stub(:generate_token, "token") do
        get start_chat_path(booking.client_token, format: :json)
      end
    end
    assert_response :success

    open_tok_config = {
      "sessionId" => booking.reload.init_session_id,
      "apiKey" => "ot_api_key",
      "token" => "token"
    }
    assert_equal open_tok_config, JSON.parse(response.body)
  end

  class TimesheetTest < ActionDispatch::IntegrationTest
    def create_chat
      user = create(:user)
      chat = create(:booking, user: user, booking_time: Time.current).reload
      chat.user = user
      chat
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
      new_user_session(chat.user)

      assert_changes -> { ChatTimesheet.last&.pro_start }, from: nil do
        post start_clock_chat_path(chat.professional_token, format: :json)
      end
    end
  end

  test "returns an error for a booking for the pro if logged out" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload
    post start_clock_chat_path(booking.professional_token, format: :json)
    assert_equal "You must login to join this video chat.", JSON.parse(response.body)["error"]
  end

  test "returns an error if booking has payment transactions" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload
    create(:payment_transaction, booking: booking)

    post start_clock_chat_path(booking.client_token, format: :json)
    assert_equal "You already had a call session on this booking.", JSON.parse(response.body)["error"]
  end
end
