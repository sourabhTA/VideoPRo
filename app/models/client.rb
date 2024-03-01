class Client < ApplicationRecord
  has_secure_token
  has_one :review
  has_one :booking
  accepts_nested_attributes_for :booking
  has_many :user_emails, as: :emailable

  validates :phone_number, phone: { possible: true, types: [:mobile], countries: [:us] }
  scope :email_subscribed, -> { where(email_subscription: true) }
  scope :have_tokens, -> { where.not(token: nil) }

  def to_s
    full_name
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
