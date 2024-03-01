require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "#profile when user is not found it redirects" do
    get show_profile_path(slug: "no-user")
    assert_equal "Profile doesn't exist.", flash[:alert]
    assert_redirected_to root_path
  end

  test "#claim_business when user is not found it redirects" do
    get claim_business_profile_path(slug: "no-user")
    assert_equal "Profile doesn't exist.", flash[:alert]
    assert_redirected_to root_path
  end
end
