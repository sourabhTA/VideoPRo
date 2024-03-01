require "test_helper"

class ChatsControllerAdminVideoChatTest < ActionDispatch::IntegrationTest
  test "renders an admin video chat for a client" do
    video_chat = create(:admin_video_chat, name: "Kevin", email: build(:user).email).reload
    get chat_path(video_chat.client_token)

    assert_response :success
    assert_match "Hi Kevin!", response.body
  end

  test "renders an admin video chat for an admin" do
    new_admin_user_session
    video_chat = create(:admin_video_chat, email: build(:user).email).reload
    get chat_path(video_chat.professional_token)

    assert_response :success
    assert_match "Hi Video Chat A Pro!", response.body
  end

  test "redirects if AdminVideoChat cannot be found" do
    get chat_path("no_session")

    assert_redirected_to root_path
    assert_equal "You are trying to access the wrong page, please contact support.", flash[:alert]
  end

  test "redirects a when the admin is logged out" do
    video_chat = create(:admin_video_chat).reload
    get chat_path(video_chat.professional_token)

    assert_redirected_to new_admin_user_session_path
    assert_equal "You must login to join this video chat.", flash[:warning]
  end
end
