json.set! :notifications do
  json.array! @notifications do |notify|
    json.id notify.id
    json.title notify.title
    json.message notify.message
    json.is_read notify.is_read_by_user(@current_user)
    json.from_id notify.from_id
    json.to_id notify.to_id
    json.review_id notify.review_id
    json.videochat_id notify.videochat_id
    json.booking_id notify.booking_id
    json.chat_time notify.chat_time
    json.user_group notify.user_group

    json.created_at notify.created_at
    json.updated_at notify.updated_at
  end
end
