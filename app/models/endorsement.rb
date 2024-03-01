class Endorsement < ApplicationRecord
  mount_uploader :image, ImageUploader
  validates :image, :alt, :link, presence: true
end
