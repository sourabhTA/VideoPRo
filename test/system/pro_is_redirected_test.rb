require "application_system_test_case"

class ProIsRedirectedTest < ApplicationSystemTestCase
  let(:sign_in_page) { Pages::NewUserSessionPage.new }

  test "it redirects to booking after signin" do
    pro = create(:user, password: "password")
    booking = create(:booking, user: pro, booking_time: 5.minutes.ago)
    visit chat_path(booking.professional_token)

    assert sign_in_page.on_page?
    assert sign_in_page.has_must_chat_warning?
    sign_in_page
      .fill_in_email(pro.email)
      .fill_in_password("password")
      .press_sign_in

    assert_equal chat_path(booking.professional_token), current_path
  end

  test "it redirects to admin chat after signin" do
    admin = create(:admin_user, password: "password")
    chat = create(:admin_video_chat).reload
    visit chat_path(chat.professional_token)

    assert sign_in_page.on_page?
    assert sign_in_page.has_must_chat_warning?
    sign_in_page
      .fill_in_email(admin.email)
      .fill_in_password("password")
      .press_sign_in

    assert_equal chat_path(chat.professional_token), current_path
  end
end
