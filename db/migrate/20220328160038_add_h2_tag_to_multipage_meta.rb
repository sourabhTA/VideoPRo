class AddH2TagToMultipageMeta < ActiveRecord::Migration[5.2]
  def change
    add_column :multipage_meta, :h2_tag, :string, default: ""
  end
end
