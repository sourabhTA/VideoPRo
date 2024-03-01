class ScheduledChatsController < AuthenticatedController
  helper_method :scheduled_chats, :monetized_bookings, :completed_bookings, :completed_chats

  private

  def completed_bookings
    @completed_bookings ||= bookings.booking_completed
  end

  def monetized_bookings
    @monetized_bookings ||= bookings.in_completed.upcoming
  end

  def scheduled_chats
    @scheduled_chats ||= video_chats.upcoming_avail.out_order
  end

  def completed_chats
    @completed_chats ||= video_chats.completed.in_order
  end

  def bookings
    @bookings ||= current_user.bookings.includes(:client, :user).in_order
  end

  def video_chats
    @video_chats ||= VideoChat.includes(:sender, :receiver).where(<<~SQL, user_id: current_user.id)
      user_id = :user_id or
      from_id = :user_id or
      to_id = :user_id
    SQL
  end
end
