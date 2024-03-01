class BusinessPicture < ApplicationRecord
  belongs_to :user, optional: true
  mount_uploader :picture, PictureUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
end
