Recaptcha.configure do |config|
  config.site_key = ENV.fetch("recaptcha_site_key")
  config.secret_key = ENV.fetch("recaptcha_secret_key")
end
