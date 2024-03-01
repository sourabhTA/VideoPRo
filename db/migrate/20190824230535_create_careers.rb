class CreateCareers < ActiveRecord::Migration[5.2]
  def change
    create_table :careers do |t|
      t.string :image
      t.string :title
      t.text :content
      t.string :button1_text
      t.string :button1_link
      t.string :button2_text
      t.string :button2_link

      t.timestamps
    end
  end
end
