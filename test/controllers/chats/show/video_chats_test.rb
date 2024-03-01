require "test_helper"

class ChatsControllerVideoChatTest < ActionDispatch::IntegrationTest
  test "renders a video chat" do
    video_chat = create(:video_chat, receiver: create(:user, name: "Kevin"))
    get chat_path(video_chat.session_id)

    assert_response :success
    assert_match "Hi Kevin!", response.body
  end

  test "renders a video chat for the sender" do
    video_chat = create(:video_chat, sender: create(:user, name: "Shane"), receiver: create(:user))
    new_user_session(video_chat.sender)
    get chat_path(video_chat.session_id)

    assert_response :success
    assert_match "Hi Shane!", response.body
  end

  test "redirects if VideoChat cannot be found" do
    get chat_path("no_session")

    assert_redirected_to root_path
    assert_equal "You are trying to access the wrong page, please contact support.", flash[:alert]
  end

  test "redirects if VideoChat has no minutes available" do
    video_chat_session = create(:video_chat, seconds_left: 0).session_id

    get chat_path(video_chat_session)

    assert_redirected_to root_path
    assert_equal "No minutes available.", flash[:warning]
  end

  test "it redirects when VideoChat is too early" do
    user = create(:user)
    video_chat = create(:video_chat, creator: user, sender: user, timings: 1.minute.from_now)

    get start_chat_path(video_chat.session_id)

    assert_redirected_to root_path
    assert_equal "Your Time is not started yet.", flash[:alert]
  end

  test "it lets you wait when VideoChat is too early" do
    user = create(:user)
    video_chat = create(:video_chat, creator: user, sender: user, timings: 23.seconds.from_now)

    get chat_path(video_chat.session_id)

    assert_response :success
    assert_match "Call starts in less than a minute", response.body
  end

  test "it redirects when VideoChat is too late" do
    user = create(:user)
    video_chat = create(:video_chat, creator: user, sender: user, timings: 60.minutes.ago)

    get chat_path(video_chat.session_id)

    assert_redirected_to root_path
    assert_equal "This Video Chat link is expired, please contact Support.", flash[:alert]
  end
end
