FactoryBot.define do
  factory :payment_transaction do
    booking
    amount { 4.63 }
    time_used { 119 }
    transaction_status { ["paid", "unpaid"].sample }
    transaction_code { "ch_123456789" }
    stripe_fee { 0.43 }
    net_amount { 4.19 }
    application_fee { 0.43 }
    customer_amount { 1.38 }
  end
end
