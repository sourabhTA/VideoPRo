class SmsSetting < ApplicationRecord
  validates :api_key, presence: true
  validates :api_secret, presence: true
  validates :phone_number, presence: true
end
