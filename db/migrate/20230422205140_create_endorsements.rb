class CreateEndorsements < ActiveRecord::Migration[5.2]
  def change
    create_table :endorsements do |t|
      t.string :image, null: false
      t.string :alt
      t.string :link

      t.timestamps
    end
  end
end
