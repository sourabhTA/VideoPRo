FactoryBot.define do
  factory :review do
    user
    booking
    client
    reviewer_name { Faker::FunnyName.three_word_name }
    comment { Faker::Marketing.buzzwords }
    rating { (1..5).to_a.sample }
  end
end
