class Claim < ApplicationRecord
  belongs_to :user

  validates :email, uniqueness: { scope: :user_id, message: "is already used to claim this business." }

  after_create :notify_admin

  scope :approved, -> { where(is_approved: true) }

  def notify_admin
    GenericMailer.profile_claimed(self).deliver
  end

end
