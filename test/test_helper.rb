ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "minitest/mock"
require "rails/test_help"
Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |f| require f }

class ActiveSupport::TestCase
  fixtures :all
  include FactoryBot::Syntax::Methods
  include EmailSupport
  include ControllerSupport
  include StubS3

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
