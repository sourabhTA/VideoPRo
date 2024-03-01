class AddVideoUrlDescriptionToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :video_url_description, :string, default: ""
  end
end
