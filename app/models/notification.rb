class Notification < ApplicationRecord
	has_many :notification_recipients
	#enum user_group: [:All, :Business, :Pro] TO BE DONE LATER AS NOT LETTING SAVED WITH VALUES
	scope :group_notifications, -> { where("user_group IN (?)", ["All","Business","Pro"]) }

	def is_read_by_user(user)
		user_group.present?  ? !!notification_recipients.find_by_user_id(user.id)&.is_read : is_read
	end

end
