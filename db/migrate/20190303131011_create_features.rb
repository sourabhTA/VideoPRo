class CreateFeatures < ActiveRecord::Migration[5.2]
  def change
    remove_column :plans, :features
    create_table :features do |t|
      t.integer :plan_id
      t.string :title

      t.timestamps
    end
  end
end
