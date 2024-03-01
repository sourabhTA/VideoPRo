class HomePageTrade < ApplicationRecord
  mount_uploader :video, VideoUploader
  mount_uploader :poster, ImageUploader
end
