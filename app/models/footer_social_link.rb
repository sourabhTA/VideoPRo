class FooterSocialLink < ApplicationRecord
  validates :name, :url, presence: true
  validates :name, uniqueness: true
end
