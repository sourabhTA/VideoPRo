class AddButtonAttributesToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :shop_button_text, :string
    add_column :pages, :shop_button_link, :string
  end
end
