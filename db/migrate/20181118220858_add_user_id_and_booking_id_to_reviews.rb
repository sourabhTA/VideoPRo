class AddUserIdAndBookingIdToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :user_id, :integer
    add_column :reviews, :booking_id, :integer
  end
end
