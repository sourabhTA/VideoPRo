class AddReviewIdToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :review_id, :integer
    add_column :notifications, :of_type, :string, default: ""
  end
end
