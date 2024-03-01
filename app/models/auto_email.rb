class AutoEmail < ApplicationRecord
  
  belongs_to :category, optional: true
  mount_uploader :image, ImageUploader

  validates :number_of_days, :segment, :subject, :pre_header, :content, presence: true
  validates :category_id, :role, presence: true, unless: :for_all?
end
