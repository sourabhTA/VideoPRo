class AddAdditionalColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :linkedin_url, :string
    add_column :users, :video_url, :string
    add_column :users, :product_knowledge, :text
    add_column :users, :specialties, :text
  end
end
