require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  extend LetSupport
  include PageSupport

  driven_by :rack_test
  # driven_by :selenium, using: :chrome, screen_size: [1200, 800]
end
