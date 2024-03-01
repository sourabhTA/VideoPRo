require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  test "send_videochat_link_to_admins only sends to super admins" do
    email = BookingMailer.send_videochat_link_to_admins(create(:booking))

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["admin_email@example.com"], email.to
  end
end
