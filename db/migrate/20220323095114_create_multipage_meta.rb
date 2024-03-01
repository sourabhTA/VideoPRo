class CreateMultipageMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :multipage_meta do |t|
      t.string :title, default: ""
      t.string :description, default: ""
      t.string :h1_tag, default: ""
      t.string :page_type, default: ""

      t.timestamps
    end
  end
end
