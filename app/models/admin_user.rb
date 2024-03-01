class AdminUser < ApplicationRecord
  devise :database_authenticatable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable

  has_one :admin_permission, dependent: :destroy

  scope :super_admins, -> {
    joins(:admin_permission).where(admin_permissions: {super_admin: true})
  }

  def self.notice_emails
    AdminUser.super_admins.pluck(:email).join(";")
  end

  def admin_permission_attributes=(attrs)
    if admin_permission.blank?
      build_admin_permission
    end

    admin_permission.attributes = attrs
    admin_permission.save
  end

  def self.default_time_zone
    "Eastern Time (US & Canada)"
  end
end
