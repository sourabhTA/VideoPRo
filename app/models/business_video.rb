class BusinessVideo < ApplicationRecord
  belongs_to :user, optional: true
end
