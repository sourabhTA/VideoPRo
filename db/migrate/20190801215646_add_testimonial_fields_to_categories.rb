class AddTestimonialFieldsToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :display_name, :string
    add_column :categories, :rating, :integer, default: 5
    add_column :categories, :review, :text
  end
end
