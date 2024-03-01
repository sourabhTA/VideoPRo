class CreateFooterSocialLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :footer_social_links do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
