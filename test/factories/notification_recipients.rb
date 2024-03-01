FactoryBot.define do
  factory :notification_recipient do
    user_id { 1 }
    notification_id { 1 }
    is_read { false }
  end
end
