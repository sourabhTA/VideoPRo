class CreateAutoEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :auto_emails do |t|
      t.integer :category_id
      t.string :segment
      t.string :role
      t.integer :number_of_days
      t.text :subject
      t.text :pre_header
      t.string :image
      t.text :content
      t.string :button_text
      t.text :button_url
      t.boolean :automation, default: false

      t.timestamps
    end
  end
end
