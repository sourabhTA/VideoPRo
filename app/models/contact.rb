class Contact < ApplicationRecord
  validates :name, :email, :body, presence: true
  after_create :notify_admin

  def notify_admin
    GenericMailer.send_contact_us(self).deliver
  end
end
