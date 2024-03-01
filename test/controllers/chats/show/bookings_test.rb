require "test_helper"

class ChatsControllerBookingsTest < ActionDispatch::IntegrationTest
  test "renders a booking for the client" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload
    booking.client.update(first_name: "Kevin")

    get chat_path(booking.client_token)

    assert_response :success
    assert_match "Hi Kevin!", response.body
  end

  test "renders a booking for the pro if logged in" do
    user = create(:user, name: "Hon")
    new_user_session(user)
    booking = create(:booking, user: user, booking_time: Time.current).reload

    get chat_path(booking.professional_token)

    assert_response :success
    assert_match "Hi Hon!", response.body
  end

  test "redirects a booking for the pro if logged out" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload
    get chat_path(booking.professional_token)

    assert_response :redirect
    assert_equal "You must login to join this video chat.", flash[:warning]
  end

  test "redirects if booking has payment transactions" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: Time.current).reload
    create(:payment_transaction, booking: booking)

    get chat_path(booking.client_token)

    assert_redirected_to root_path
    assert_equal "You already had a call session on this booking.", flash[:alert]
  end

  test "redirects if booking cannot be found" do
    get chat_path("no_session")

    assert_redirected_to root_path
    assert_equal "You are trying to access the wrong page, please contact support.", flash[:alert]
  end

  test "it lets you wait when booking is too early" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: 23.seconds.from_now).reload

    get chat_path(booking.client_token)

    assert_response :success
    assert_match "Call starts in less than a minute", response.body
  end

  test "it redirects when booking is too early" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: 1.minute.from_now).reload

    get start_chat_path(booking.client_token)

    assert_redirected_to root_path
    assert_equal "Your Time is not started yet.", flash[:alert]
  end

  test "it redirects when booking is too late" do
    user = create(:user)
    booking = create(:booking, user: user, booking_time: 60.minutes.ago).reload

    get chat_path(booking.client_token)

    assert_redirected_to root_path
    assert_equal "This Video Chat link is expired, please contact Support.", flash[:alert]
  end
end
