FactoryBot.define do
  factory :video_chat do
    transient do
      seconds_left { 300 }
    end

    business { association :user, seconds_left: seconds_left }
    association :creator, factory: :user
    association :sender, factory: :user

    time_zone { User::EASTERN }
    email { "email@example.com" }

    session_id { SecureRandom.uuid }
    name { "MyString" }
    timings { Time.current }
    sequence(:phone_number) { |n|
      ["1-800-555-" + n.to_s.rjust(4, "010"),
        "1-800-555-" + n.to_s.rjust(4, "000")].join(";")
    }
  end
end
