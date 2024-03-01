class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :stripe_id
      t.string :name
      t.decimal :display_price
      t.boolean :is_active, default: true
      t.text :features

      t.timestamps
    end
  end
end
