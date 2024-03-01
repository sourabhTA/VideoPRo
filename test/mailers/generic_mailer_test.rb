require "test_helper"

class GenericMailerTest < ActionMailer::TestCase
  [
    ["profile_claimed", FactoryBot.build(:user)],
    ["send_contact_us", OpenStruct.new(name: "")],
    ["user_created", FactoryBot.build(:user)]
  ].each do |email, params|
    test "#{email} only sends to super admins" do
      email = GenericMailer.send(email.to_sym, params)

      assert_emails 1 do
        email.deliver_now
      end

      assert_equal ["admin_email@example.com"], email.to
    end
  end

  test "send_resume only sends to super admins" do
    email = GenericMailer.send_resume("", "", "", "", "", "", "", "", "")

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["admin_email@example.com"], email.to
  end
end
