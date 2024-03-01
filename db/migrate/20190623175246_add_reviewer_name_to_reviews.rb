class AddReviewerNameToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :reviewer_name, :string
  end
end
