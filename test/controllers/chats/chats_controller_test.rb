require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  def params(partner_id: OpenTokClient.api_key, session_id: nil, status: "available")
    {
      "id": "b40ef09b-3811-4726-b508-e41a0f96c68f",
      "event": "archive",
      "createdAt": 1384221380000,
      "duration": 328,
      "name": "Foo",
      "partnerId": partner_id,
      "reason": "",
      "resolution": "640x480",
      "sessionId": session_id || "2_MX40NzIwMzJ-flR1ZSBPY3QgMjkgMTI6MTM6MjMgUERUIDIwMTN-MC45NDQ2MzE2NH4",
      "size": 18023312,
      "status": status,
      "url": "https://tokbox.com.archive2.s3.amazonaws.com/123456/b40ef09b-3811-4726-b508-e41a0f96c68f/archive.mp4"
    }
  end

  test "#tokbox_callback does not update the archive id when status is available" do
    stub_open_tok {
      booking = create(:booking, archive_id: nil, init_session_id: SecureRandom.uuid)
      post tokbox_callback_chats_path(params(session_id: booking.init_session_id))
      assert_response :ok
      assert_nil booking.reload.archive_id
    }
  end

  test "#tokbox_callback updates the archive id by init_session_id" do
    stub_open_tok {
      booking = create(:booking, archive_id: nil, init_session_id: SecureRandom.uuid)
      post tokbox_callback_chats_path(params(session_id: booking.init_session_id, status: "uploaded"))
      assert_response :ok
      assert_equal "b40ef09b-3811-4726-b508-e41a0f96c68f", booking.reload.archive_id
    }
  end

  test "#tokbox_callback updates the archive id by session_id" do
    stub_open_tok {
      booking = create(:booking, archive_id: nil, session_id: SecureRandom.uuid)
      post tokbox_callback_chats_path(params(session_id: booking.session_id, status: "uploaded"))
      assert_response :ok
      assert_equal "b40ef09b-3811-4726-b508-e41a0f96c68f", booking.reload.archive_id
    }
  end

  test "#tokbox_callback does not update the archive id unless it's blank" do
    stub_open_tok {
      booking = create(:booking, archive_id: "123", init_session_id: SecureRandom.uuid)
      post tokbox_callback_chats_path(params(session_id: booking.init_session_id, status: "uploaded"))
      assert_response :ok
      assert_equal "123", booking.reload.archive_id
    }
  end

  test "#tokbox_callback returns 404 if partnerId doesn't match" do
    stub_open_tok {
      post tokbox_callback_chats_path(params(partner_id: "fakeid"))
      assert_response :not_found
    }
  end

  test "#tokbox_callback returns 404 if partnerId is missing" do
    stub_open_tok {
      post tokbox_callback_chats_path
      assert_response :not_found
    }
  end

  test "#tokbox_callback returns 200 if sessionId is missing" do
    stub_open_tok {
      post tokbox_callback_chats_path(partnerId: OpenTokClient.api_key)
      assert_response :ok
    }
  end

  test "#tokbox_callback returns 200 if id is missing" do
    stub_open_tok {
      post tokbox_callback_chats_path(partnerId: OpenTokClient.api_key)
      assert_response :ok
    }
  end

  test "#tokbox_callback returns 200 if status is missing" do
    stub_open_tok {
      post tokbox_callback_chats_path(partnerId: OpenTokClient.api_key)
      assert_response :ok
    }
  end
end
