class AddRenderCmsToAppSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :is_render_cms, :boolean, default: true
  end
end
