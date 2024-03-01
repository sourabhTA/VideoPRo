class Api::V1::NotificationsController < Api::V1::BaseController
	before_action :user_authenticate, only: [:get_notification, :booking_details, :get_review_details, :get_video_chat_summary]

	def get_notification
		begin
			vchat_ids = video_chats(@current_user).upcoming_avail.ids
			booking_ids = @current_user.bookings.in_completed.upcoming.ids

			@notifications = Notification
												.where('(to_id = (?) AND videochat_id IN (?))
																	OR booking_id IN (?)
																	OR user_group = (?)
																	OR user_group = (?)
																	OR
																	(
																		to_id = (?)
																		AND videochat_id IS ?
																		AND booking_id IS ?
																	)
																	OR (to_id = (?) AND of_type = (?))',
													@current_user.id, vchat_ids,
													booking_ids,
													@current_user.role.camelize,
													"All",
													@current_user.id, nil, nil,
													@current_user.id, "end_call"
												)
				.where(created_at: (Time.now - 24.hours)..Time.now).order(created_at: :desc)
			render

			@notifications.update(is_read: true) if @notifications.exists?(is_read: false)
			@notifications.group_notifications.each do |nfs|
				nfs.notification_recipients.find_or_create_by(user_id: @current_user.id, is_read: true)
			end
		rescue Exception => e
			render json: { error: "Something went wrong -> #{e.message}" }, status: 408
		end
	end

	# API for single booking details
	def booking_details
		begin
			if params[:id].present? && params[:type] == "Booking"
				@booking = Booking.find(params[:id])
			else
				render json: { message: "Required Booking ID" }
			end
		rescue Exception => e
			render json: { error: "Something went wrong -> #{e.message}" }, status: 408
		end
	end

	# API for review notification details
	def get_review_details
		begin
			if params[:id].present?
				render json: { review: Review.find(params[:id]) }
			else
				render json: { message: "Required Review ID" }
			end
		rescue Exception => e
			render json: { error: "Something went wrong -> #{e.message}" }, status: 408
		end
	end

	# API for Video Chat Summary details
	def get_video_chat_summary
		begin
			if params[:id].present?
				@booking = Booking.find(params[:id])
				time_used = Time.at(@booking.time_used).utc.strftime('%H:%M:%S')
				earned = ActionController::Base.helpers.number_to_currency(@booking&.customer_share) if (@booking.payment_transactions.count > 0)
				render json: { earned: earned, time_used: time_used }
			else
				render json: { message: "Required Booking ID" }
			end
		rescue Exception => e
			render json: { error: "Something went wrong -> #{e.message}" }, status: 408
		end
	end

	private

	  def video_chats(current_user)
	    @video_chats ||= VideoChat.includes(:sender, :receiver).where(<<~SQL, user_id: current_user.id)
	      user_id = :user_id or
	      from_id = :user_id or
	      to_id = :user_id
	    SQL
	  end
end
