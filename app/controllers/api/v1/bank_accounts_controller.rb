class Api::V1::BankAccountsController < Api::V1::BaseController
	before_action :user_authenticate, only: [:get_earnings]

	def get_earnings
		begin
			bookings = @current_user.bookings.where("time_used NOT IN (?) and is_call_ended NOT IN (?)", 0, false).includes(:payment_transactions).order(created_at: :desc).map{ |b| [b.client.first_name, b&.customer_share.round(2), Time.at(b.time_used).utc.strftime('%H:%M:%S')] if b&.payment_transactions&.first }.compact
			render json: { bookings: bookings }
		rescue Exception => e
			render json: { error: "Something went wrong." }, status: 401	
		end
	end

end
