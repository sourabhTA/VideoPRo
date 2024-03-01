class Review < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :booking, optional: true
  belongs_to :client, optional: true
  belongs_to :video_chat, optional: true

  validates :rating, :comment, :reviewer_name, presence: true
  after_create :create_review_notification

  def create_review_notification
    return unless self.user_id.present?

      current_user = self.user
      if current_user.pro? || current_user.business?
        Notification.create(
          title: "New Review Received",
          message: "#{current_user.name} You received a #{self.rating} star review from #{self.reviewer_name}",
          to_id: current_user.id,
          review_id: self.id
        )
      end
    end

    def notify_user
      GenericMailer.you_are_reviewed(self).deliver
    end
  end
