json.booking do
	json.id @booking.id
	json.booking_date @booking.booking_date
	json.booking_time @booking.booking_time.strftime("%I:%M %p %Z")
	json.city @booking.city
	json.state @booking.state
	json.city @booking.city
	json.issue @booking.issue
	json.chat_time @booking.booking_time
	json.set! :client_detail do
		json.client_name @booking.client.first_name
		json.client_email @booking.client.email
	end

	json.created_at @booking.created_at
	json.updated_at @booking.updated_at
end
