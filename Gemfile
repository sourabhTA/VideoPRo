source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.2"

gem "rails", "5.2.4.3"

gem "pg", ">= 0.18", "< 2.0"

gem "activeadmin"
gem "active_model_serializers"
gem "aws-sdk-s3", "~> 1.87.0", require: false
gem "bootstrap", "~> 4.1.0"
gem "bootstrap3-datetimepicker-rails"
gem "bootstrap4-kaminari-views"
gem "bootstrap-generators", github: "decioferreira/bootstrap-generators"
gem "byebug"
gem "canonical-rails"
gem "carrierwave"
gem "cocoon"
gem "coffee-rails", "~> 4.2"
gem "combined_time_select"
gem "comfortable_mexican_sofa", "~> 2.0.0"
gem "daemons", "~> 1.3"
gem "delayed_job_active_record"
gem "devise"
gem "execjs"
gem "faker", "~> 2.12"
gem "figaro" # we"ll use it to store our API keys
gem "fog-aws"
gem "font-awesome-sass", "~> 6.4"
gem "friendly_id"
gem "geocoder"
gem "gon" # this one to expose our API keys to JS
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "jquery-slick-rails"
gem "kaminari"
gem "mini_magick"
gem "momentjs-rails"
gem "money-rails"
gem "nexmo"
gem "opentok" # SDK to use TokBox library
gem "phonelib"
gem "puma"
gem "purgecss_rails", require: false
gem "rack-attack"
gem "recaptcha"
gem "rmagick"
gem "sass-rails", "~> 5.0"
gem "sendgrid-actionmailer", "~> 3.1"
gem "sentry-raven"
gem "shortener"
gem "sitemap_generator"
gem "stripe"
gem "tod", "~> 2.2"
gem "uglifier"
gem "validate_url"

group :development do
  gem "brakeman"
  gem "letter_opener"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "mina", "~> 1.2"
  gem "standard"
end

group :development, :test do
  gem "factory_bot_rails"
  gem "pry-rails"
end

group :test do
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "acts_as_paranoid", "~> 0.7.3"
gem "devise_token_auth"
gem "fcm"
gem "gmaps4rails", "~> 2.1", ">= 2.1.2"
gem "mailtrap", "~> 0.2.1"
gem "omniauth"
gem "rack-cors"
gem "underscore-rails", "~> 1.8", ">= 1.8.3"
gem "will_paginate", "~> 3.3", ">= 3.3.1"
