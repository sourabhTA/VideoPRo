FactoryBot.define do
  factory :business_address do
    user
    city { Faker::Address.city }
    zip { Faker::Address.zip }
    price { 1.50 }
  end
end
