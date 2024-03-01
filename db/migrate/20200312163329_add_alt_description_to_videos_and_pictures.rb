class AddAltDescriptionToVideosAndPictures < ActiveRecord::Migration[5.2]
  def change
    add_column :business_pictures, :alt, :string
    add_column :business_pictures, :description, :string
    add_column :business_videos, :alt, :string
    add_column :business_videos, :description, :string
    add_column :business_addresses, :url, :string
  end
end
