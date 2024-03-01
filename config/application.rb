require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Videochatpro
  class Application < Rails::Application
    # Ensuring that ActiveStorage routes are loaded before Comfy's globbing
    # route. Without this file serving routes are inaccessible.
    config.railties_order = [ActiveStorage::Engine, :main_app, :all]
    config.active_record.time_zone_aware_types = [:datetime]

    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.1
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load_paths << Rails.root.join("lib")
    config.active_record.schema_format = :sql

    # # Date
    # Date::DATE_FORMATS[:default] = "%m-%d-%Y"
    #
    # # Time
    # Time::DATE_FORMATS[:default] = "%m-%d-%Y %I:%M %P"

    config.time_zone = "Central Time (US & Canada)"
    # config.active_record.default_timezone = :local

    # Time::DATE_FORMATS[:default] = "%m/%d/%Y"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.middleware.use Rack::Attack
    config.active_job.queue_adapter = ( Rails.env.production? || Rails.env.staging? ) ? :delayed_job : :inline

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
        headers: :any,
        expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
        methods: [:get, :post, :options, :delete, :put, :patch]
      end
    end
  end
end

# encoding: utf-8
