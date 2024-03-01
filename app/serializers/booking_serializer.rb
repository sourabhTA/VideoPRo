class BookingSerializer < ActiveModel::Serializer
  attributes ["id", "user_id", "booking_date", "booking_time", "city", "state", "issue",
    "time_zone", "session_id", "client_id", "slug", "time_used", "client"]

  def client
    object.client
  end
end
