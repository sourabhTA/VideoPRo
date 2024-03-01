FactoryBot.define do
  factory :admin_user do
    email { SecureRandom.uuid + "+admin@example.com" }
    password { "password" }

    factory :super_admin_user do
      after(:create) do |record|
        create(:admin_permission, admin_user: record, super_admin: true)
      end
    end
  end
end
