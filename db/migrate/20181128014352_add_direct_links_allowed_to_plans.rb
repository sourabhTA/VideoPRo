class AddDirectLinksAllowedToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :direct_links_allowed, :integer
  end
end
