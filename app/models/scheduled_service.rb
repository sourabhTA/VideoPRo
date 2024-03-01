class ScheduledService < ApplicationRecord
  belongs_to :user
  PROPERTY_TYPES = ['Own', 'Rent', 'Lease']
  HOME_TYPES = ['Single family', 'Apartment', 'Duplex', 'Townhouse', 'Trailer condo', 'Modular', 'Manufactured', 'Cabin', 'Tiny home', 'Yurt']
  SCHEDULED_TIMES = ['Today', 'Tomorrow', 'Within 3 days', 'Within 7-10 days', 'Within 30 days']

  validates :phone_number, phone: { possible: true, types: [:mobile], countries: [:us] }

  after_create :notify_business

  def notify_business
    GenericMailer.scheduled_service_created(self).deliver_now
  end

end
