require "test_helper"

class UserFilterTest < ActiveSupport::TestCase
  attr_reader :pro
  attr_reader :business

  def create_users
    @pro = create(:user, name: "The pro!", role: "pro", is_featured: true)
    create(:user, name: "The employee!", role: "employee")
    @business = create(:user, name: "The business!", role: "business")
    create(:user, name: nil)
    create(:user).update(slug: nil)
    create(:user, is_hidden: true)
    create(:user, name: "Scraper", scraped_link: "yellowpages")
  end

  def setup
    create_users
  end

  test "it does not include users missing names" do
    users = UserFilter.search
    assert_equal 2, users.size
    assert_equal "The pro!", users.first.name
    assert_equal "The business!", users.last.name
  end

  test "it does not include hidden users" do
    users = UserFilter.search
    assert_equal 2, users.size
    assert_equal "The pro!", users.first.name
    assert_equal "The business!", users.last.name
  end

  test "it does not include users missing slugs" do
    users = UserFilter.search
    assert_equal 2, users.size
    assert_equal "The pro!", users.first.name
    assert_equal "The business!", users.last.name
  end

  test "it does not include scraped users" do
    users = UserFilter.search
    assert_equal 2, users.size
    assert_equal "The pro!", users.first.name
    assert_equal "The business!", users.last.name
  end

  test "it does not include employees" do
    users = UserFilter.search
    assert_equal 2, users.size
    assert_equal "The pro!", users.first.name
    assert_equal "The business!", users.last.name
  end

  test "it only includes pros" do
    users = UserFilter.search(role: "pro")
    assert_equal 1, users.size
    assert_equal "The pro!", users.first.name
  end

  test "it only includes businesses" do
    users = UserFilter.search(role: "business")
    assert_equal 1, users.size
    assert_equal "The business!", users.first.name
  end

  test "it only includes users with license trades" do
    create(:license_information, user: business, category: Category.find_by(name: "Plumbers"))
    [
      "Plumbers",
      "plumbers",
      "  plumbers   "
    ].each do |cat|
      users = UserFilter.search(role: "business", category_name: cat)
      assert_equal 1, users.size
      assert_equal "The business!", users.first.name
    end
  end

  test "with no sort, is sorts by featured desc" do
    create(:user, name: "Second!", role: "pro", is_featured: true)
    users = UserFilter.search
    assert_equal 3, users.size
    assert_equal "The pro!", users[0].name
    assert_equal "Second!", users[1].name
    assert_equal [true, true, false], users.map(&:is_featured)
  end
end
