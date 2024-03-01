class StripeEvent < ApplicationRecord
  belongs_to :user, optional: true
end
