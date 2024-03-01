json.set! :scheduled_chats do
  json.array! scheduled_chats do |chat|
    json.name chat.name
    json.session_id chat.session_id
    json.email chat.email_receivers_without_sender.to_sentence
    json.created_by chat.sender.email

    json.timings chat.timings.strftime("%l:%M %p %Z")
    json.archive_id chat.archive_id
    json.timings chat.timings
    json.id chat.id
  end
end

json.set! :monetized_bookings do
  json.array! monetized_bookings do |chat|
    json.booking_date chat.booking_date
    json.booking_time chat..booking_time.strftime("%l:%M %p %Z")
    json.professional_token chatprofessional_token
    json.client_name chat.client.first_name
    json.archive_id chat.archive_id
    json.timings chat.timings.strftime("%l:%M %p %Z")
    json.timings chat.timings
    json.booking_time chat.booking_time
    json.id chat.id
  end
end

json.set! :completed_bookings do
  json.array! completed_bookings do |chat|
    json.booking_date chat.booking_date
    json.booking_time chat..booking_time.strftime("%l:%M %p %Z")
    json.professional_token chatprofessional_token
    json.client_name chat.client.first_name
    json.archive_id chat.archive_id
    json.timings chat.timings.strftime("%l:%M %p %Z")
    json.timings chat.timings
    json.booking_time chat.booking_time
    json.id chat.id
  end
end
