FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { SecureRandom.uuid + "@example.com" }
    sequence(:phone_number) { |n| "1-800-555-0" + n.to_s.rjust(3, "10") }
    password { "password" }
    agree_to_terms_and_service { true }
    stripe_subscription_id { SecureRandom.uuid }
    confirmed_at { 100.years.ago }
    time_zone { User::EASTERN }
    seconds_left { 36_000 }
    role { "business" }
    profile_completed { true }

    slug { SecureRandom.uuid }
    is_hidden { false }
    scraped_link { nil }

    factory :business
    factory :pro do
      role { "pro" }
    end
  end
end
