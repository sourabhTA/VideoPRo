class AddMainBackgroundImageToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :main_background_image, :string
  end
end
