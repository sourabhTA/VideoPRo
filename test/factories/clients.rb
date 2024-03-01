FactoryBot.define do
  factory :client do
    sequence(:phone_number) { |n| "1-800-555-0" + n.to_s.rjust(3, "10") }
  end
end
