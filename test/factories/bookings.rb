FactoryBot.define do
  factory :booking do
    client
    user
    user_id { create(:user).id }
    session_id { create(:admin_video_chat).session_id }
    booking_date { Date.current }
    booking_time { 1.day.ago }
    client_token { SecureRandom.uuid }
    professional_token { SecureRandom.uuid }
    time_zone { "Pacific Time (US & Canada)" }
    agree_with_terms_and_conditions { true }
    city { Faker::Address.city }
    state { Faker::Address.state }
    issue { "Broken" }
  end
end
