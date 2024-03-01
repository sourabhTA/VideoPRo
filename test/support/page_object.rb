require "capybara/minitest"

class PageObject
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def has_notice?(msg)
    has_selector? ".alert-success", text: msg
  end

  def has_error?(msg)
    has_selector? ".alert-danger", text: msg
  end

  def has_warning?(msg)
    has_selector? ".alert-warning", text: msg
  end
end
