class AddClientIdToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :client_id, :integer
  end
end
