class Blog < ApplicationRecord
  belongs_to :blog_category
  validates :title, :content, :blog_category_id, presence: true
  mount_uploader :image, ImageUploader

  def to_param
    slug
  end

end
