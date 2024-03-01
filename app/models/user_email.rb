class UserEmail < ApplicationRecord
  belongs_to :emailable, polymorphic: true

  scope :every_time, -> { where(automation: true) }
  scope :one_time, -> { where(automation: false) }
end
