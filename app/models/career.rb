class Career < ApplicationRecord
  mount_uploader :image, ImageUploader

  def self.career_list
    Career.order(created_at: :desc)
  end
end
