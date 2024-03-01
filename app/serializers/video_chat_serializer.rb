class VideoChatSerializer < ActiveModel::Serializer
  attributes ["id", "user_id", "session_id", "business_id", "is_internal", "from_id", "to_id", "timings", "time_used"]
end
