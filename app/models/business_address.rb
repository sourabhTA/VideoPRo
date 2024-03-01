class BusinessAddress < ApplicationRecord
  belongs_to :user

  validates :city, presence: true
  validates :zip, presence: true
  validates :price, presence: true
  validates :url, http_url: true, if: -> { url.present? }
end
