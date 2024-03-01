FactoryBot.define do
  factory :admin_video_chat do
    name { "MyName" }
    session_id { SecureRandom.uuid }
  end
end
