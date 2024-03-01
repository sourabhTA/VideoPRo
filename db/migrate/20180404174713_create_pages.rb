class CreatePages < ActiveRecord::Migration[5.1]
  def change
    create_table :pages do |t|
      t.string :slug
      t.string :title
      t.text :meta_keywords
      t.text :meta_description

      t.timestamps
    end
  end
end
