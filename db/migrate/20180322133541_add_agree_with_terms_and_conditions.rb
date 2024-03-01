class AddAgreeWithTermsAndConditions < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :agree_with_terms_and_conditions, :boolean, default: false
  end
end
