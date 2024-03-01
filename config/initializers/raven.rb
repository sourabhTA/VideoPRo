if Rails.env.production? || Rails.env.staging?
  Raven.configure do |config|
    config.dsn = ENV.fetch("sentry_rails_dsn")
    config.excluded_exceptions += [
      "SignalException",
      "ActionController::UnknownFormat",
      "ActionController::InvalidCrossOriginRequest"
    ]
  end
end
