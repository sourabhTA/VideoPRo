require "application_system_test_case"

class VideoChatsTest < ApplicationSystemTestCase
  let(:page) { Pages::ProfilePage.new }
  let(:index_page) { Pages::VideoChatIndexPage.new }
  let(:sign_in_page) { Pages::NewUserSessionPage.new }

  def setup
    SmsSetting.create(
      api_key: "123",
      api_secret: "456",
      phone_number: "1-555-555-5555"
    )
  end

  test "does not see estimate verbage when user is not business" do
    user = create(:pro, rate: 55)
    page = Pages::ProfileShowPage.new(user)

    page.visit_page
    assert page.on_page?

    assert page.has_selector? "h4", text: /\A\$3\.66 per minute\z/
  end

  test "sees estimate verbage when user is business" do
    user = create(:business, rate: 55)
    page = Pages::ProfileShowPage.new(user)

    page.visit_page
    assert page.on_page?

    assert page.has_selector? "h4", text: /\A\$3\.66 per minute for live video estimate\z/
  end
end
