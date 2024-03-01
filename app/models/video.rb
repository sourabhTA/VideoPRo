class Video < ApplicationRecord
  mount_uploader :video, VideoUploader
  mount_uploader :poster, ImageUploader

  SEARCH_PROMO = "search-promo"
  SEARCH_PROMO_BUSINESS = "search-promo-business"

  def self.search_promo
    find_or_initialize_by(name: SEARCH_PROMO)
  end

  def self.search_promo_business
    find_or_initialize_by(name: SEARCH_PROMO_BUSINESS)
  end
end
