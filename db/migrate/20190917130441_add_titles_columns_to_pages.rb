class AddTitlesColumnsToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :search_heading1, :text
    add_column :pages, :search_heading2, :text
    add_column :pages, :why_heading, :text
    add_column :pages, :what_heading, :text
    add_column :pages, :video_review_heading, :text
  end
end
