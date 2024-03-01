class VideoUploader < CarrierWave::Uploader::Base
  storage :file

  def self.search_promo
    new.retrieve_from_store!("search-promo.mp4")
  end

  def self.search_promo_business
    new.retrieve_from_store!("search-promo-business.mp4")
  end

  def store_dir
    "uploads/videos"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    [model.try(:name) || model.try(:title), file.extension].join(".") if original_filename.present?
  end
end
