class AppSetting < ApplicationRecord
	def self.is_render_cms
		AppSetting.first.is_render_cms
	end
end
