class Api::V1::UserController < Api::V1::BaseController
  before_action :user_authenticate, only: [:scheduled_chats, :business_videos, :get_leads,
  	:get_lead_detail, :user_update, :fcm_token_update, :logout_user,
  	:set_availability, :load_more_scheduled_chats, :get_user, :business_image_update ]

	def user_app_version
		current_version = params['current_version'] == '1.0.5' ? '1.0.5' : '1.0.7'
		render json: {
      current_version: current_version,
			android_url: ENV.fetch("android-pro"),
			ios_url: ENV.fetch("ios-pro"),
			login_string: "To become a pro or use Video Chat a Pro in your business please visit videochatapro.com and sign up."
		}
	rescue => e
		render json: { error: "Error: #{e.message}" }
	end

	def get_token
		if params[:email].present?
			user = User.find_by(email: params[:email].downcase)

			if user.present?
				is_notification = Notification.exists?(to_id: user.id, is_read: false, created_at: (Time.now - 24.hours)..Time.now)
				render json: {
					user: user, token: user.tokens.values.last,
					user_role: user.role, new_notification: is_notification,
					is_paid: user.is_paid_business?,
					shared_link: user.employee? ? user&.business&.slug : user&.slug
				}
			else
				render json: {error: "User not found"}, status: 400
			end
		else
			render json: {error: "Email Required"}, status: 400
		end
	end

	def get_user
		get_token
	end

	def scheduled_chats
		begin
			monetized_bookings ||= bookings.in_completed.upcoming.limit(5)
															.map{ |x| [
																x.booking_date, x.booking_time.strftime("%l:%M %p %Z"),
																x.professional_token, x.client.first_name, archive_url(x),
																x.booking_time, x.id, x.payment_transactions.pluck(:call_time_booked).sum,
																!x.is_booking_fake, x.watermark, x.chat_available,
																(x&.chat_timesheet&.last_time_used || 0), x.expected_end_time.utc ]
															}
			completed_bookings ||= bookings.booking_completed.order(created_at: :desc).limit(5)
															.map{ |x| [
																x.booking_date, x.booking_time.strftime("%l:%M %p %Z"),
																x.professional_token, x.client.first_name, archive_url(x),
																x.booking_time, x.id, x.payment_transactions.pluck(:call_time_booked).sum, x.time_used ]
															}

			scheduled_chats ||= video_chats.upcoming_avail.out_order.limit(5)
														.map{ |vc| [
															vc.name, vc.session_id,vc.email,
															vc.timings.strftime("%l:%M %p %Z"), archive_url(vc), vc.timings,
															vc.id, vc.sender.email, vc.watermark ]
														}
			complete_video_chats ||= video_chats.completed.in_order.limit(5)
																.map{|vc| [
																	vc.name, vc.session_id,vc.email,
																	vc.timings.strftime("%l:%M %p %Z"), archive_url(vc),
																	vc.timings, vc.id, vc.sender.email, vc.time_used ]
																}

			render json: {
						monetized_bookings: monetized_bookings,
						completed_bookings: completed_bookings,
						scheduled_chats: scheduled_chats,
						complete_video_chats: complete_video_chats
					}
		rescue Exception => e
			render json: {
				error: "Something wrong to fetch detail",
				error_message: e.message
			}, status: 401
		end
	end

	def load_more_scheduled_chats
		begin
			next_schedule_chat = []
			if params[:type] == "booking"
				if params[:typeStatus] == "upcoming"
					next_schedule_chat = bookings.in_completed.upcoming.offset(params[:offset]).limit(5)
																.map{ |x| [
																	x.booking_date, x.booking_time.strftime("%l:%M %p %Z"),
																	x.professional_token, x.client.first_name, archive_url(x),
																	x.booking_time, x.id, x.payment_transactions.pluck(:call_time_booked).sum,
																	x.watermark, x.chat_available, (x&.chat_timesheet&.last_time_used || 0),
																	x.expected_end_time.utc
																]
																}
				else
					next_schedule_chat = bookings.completed.order(created_at: :desc)
																.offset(params[:offset]).limit(5).map{ |x| [
																		x.booking_date, x.booking_time.strftime("%l:%M %p %Z"),
																		x.professional_token, x.client.first_name, archive_url(x),
																		x.booking_time, x.id, x.payment_transactions.pluck(:call_time_booked).sum ]
																	}
				end
			elsif params[:type] == "video_chat"
				if params[:typeStatus] == "upcoming"
					next_schedule_chat = video_chats.upcoming_avail.out_order.offset(params[:offset])
																.limit(5).map{ |vc| [
																	vc.name, vc.session_id,vc.email,
																	vc.timings.strftime("%l:%M %p %Z"), archive_url(vc),
																	vc.timings, vc.id, vc.sender.email, vc.watermark]
																}
				else
					next_schedule_chat = video_chats.completed.in_order.offset(params[:offset]).limit(5)
																.map{ |vc| [
																	vc.name, vc.session_id,vc.email,
																	vc.timings.strftime("%l:%M %p %Z"), archive_url(vc),
																	vc.timings, vc.id, vc.sender.email]
																}
				end
			end

			render json: {next_schedule_chat: next_schedule_chat }
		rescue Exception => e
			render json: {error: "Something wrong to fetch detail", error_message: e.message }, status: 401
		end
	end

	def business_videos
		render json: {
			videos: @current_user.business_videos,
			business_pictures: @current_user.business_pictures
		}
	end

	def download_chat
    download_url = SignedUrlAdapter.new(archive_id: chat.archive_id, download_name: chat.download_name).signed_url
    if download_url
			render json: {download_url: download_url }
    else
			render json: {error: "We could not find that archive." }, status: 401
    end
	end

	def get_leads
			scheduled_services = @current_user.scheduled_services.order(created_at: :desc).map { |u|
														{ id: u.id, name: u.your_name,
															request_sent_at: u.created_at.try(:strftime, "%m/%d/%Y") } }
			render json: {leads: scheduled_services }
	end

	def get_lead_detail
		begin
			if params[:id].present?
				scheduled_services = @current_user.scheduled_services.find(params[:id])
				render json: {lead_detail: scheduled_services }
			else
				render json: {error: "Lead id required" }, status: 401
			end
		rescue Exception => e
			render json: {error: e.class.name, error_reason: e.message }, status: 401
		end
	end

	def user_update
    if user_params[:password] == user_params[:password_confirmation]
    	upload_user_image
      if (user_params[:password].blank? && @current_user.update_without_password(user_params)) || @current_user.update_attributes(user_params)
        @current_user.update_column(:profile_completed, true)
				render json: {success: "User Updated Successfully" }
      else
				render json: {error: "Something went wrong" }, status: 400
      end
    else
			render json: {error: "Confirmation doesn't match Password" }, status: 401
    end
	end

	def business_image_update
		if params[:picture].present?
			if @current_user.business_pictures.create(picture: base64_image(params[:picture]) )
				render json: {success: "User's Business Image created Successfully" }
			else
				render json: {error: "Something went wrong" }, status: 401
			end
		else
			render json: {error: "Required picture" }, status: 401
		end
	end

	def fcm_token_update
		@current_user.fcm_token << params[:fcm_token] unless @current_user.fcm_token.include?(params[:fcm_token])

		if @current_user.save
			render json: {success: "FCM Token Updated Successfully" }
		else
			render json: {error: "Something went wrong" }, status: 401
		end
	end

	def logout_user
		@current_user.update(fcm_token: "")
		render json: {message: "User Successfully logout" }
	end

	def set_availability
		field = {
			"is_#{Time.now.strftime("%A").downcase}_on": params[:status],
			"avail_update_at": Time.now.in_time_zone(@current_user.time_zone)
		}
		if @current_user.update_attributes(field)
			render json: {message: "User updated successfully" }
		else
			render json: {error: "Something went wrong" }, status: 401
		end
	end

	def forgot_password
		begin
			current_user = User.find_by(email: params[:email].downcase)
			if current_user.present?
				raw, hashed = Devise.token_generator.generate(User, :reset_password_token)

				current_user.reset_password_token = hashed
				current_user.reset_password_sent_at = Time.now.utc
				current_user.save

				DeviseMailer.reset_password_instructions(current_user, raw).deliver_now

				render json: {message: "Reset Password instructions sent to email successfully" }
			else
				render json: {message: "User Not Found" }, status: 200
			end
		rescue Exception => e
			render json: {message: "Something went wrong -> #{e.message}" }
		end
	end

	private

		def archive_url(vchat)
			( vchat.time_used > 0) ? vchat.archive_id : nil
		end

		def upload_user_image
			if params[:image_64].present?
				params[:user][:picture] =  base64_image(params[:image_64])
			end
		end

		def base64_image(base_64)
			tempfile = Tempfile.new("fileupload")
			tempfile.binmode
			tempfile.write(Base64.decode64(base_64))
			file_name = SecureRandom.hex(5)+".png"
			uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => file_name, :original_filename => file_name)
			uploaded_file.content_type = "image/png"
			uploaded_file
		end

	  def bookings
	    @bookings ||= @current_user.bookings.includes(:client, :user).in_order
	  end

	  def video_chats
	    @video_chats ||= VideoChat.includes(:sender, :receiver).where(<<~SQL, user_id: @current_user.id)
        user_id = :user_id or
        from_id = :user_id or
        to_id = :user_id
	    SQL
	  end

    def chat
	    @chat ||= begin
	      chat = VideoChat.includes(:sender).find_by(session_id: params[:id])
	      if chat.blank? && params[:id].remove(/[^-]/).size == 4
	        where = ["client_token = :token or professional_token = :token", token: params[:id]]
	        chat = Booking.includes(:user, :client).where(where).first ||
	          AdminVideoChat.where(where).first
	      end
	      chat
	    end
	  end

	  def user_params
	    accessible = [:name, :business_number, :phone_number, :email, :password, :password_confirmation, :picture, :rate, :category_id, :business_address,
	      :license_type, :description, :city, :state, :zip, :availability, :business_website, :time_zone, :email_permissions,
	      :is_monday_on, :is_tuesday_on, :is_wednesday_on, :is_thursday_on, :is_friday_on, :is_saturday_on, :is_time_set,
	      :is_sunday_on, :monday_start_time, :monday_end_time, :tuesday_start_time, :tuesday_end_time, :crop_x, :crop_y, :crop_w, :crop_h,
	      :wednesday_start_time, :wednesday_end_time, :thursday_start_time, :thursday_end_time, :friday_start_time,
	      :friday_end_time, :saturday_start_time, :saturday_end_time, :sunday_start_time, :sunday_end_time, :is_van_paid,
	      :monday_break_start_time, :monday_break_end_time, :tuesday_break_start_time, :tuesday_break_end_time, :free_of_charge,
	      :wednesday_break_start_time, :wednesday_break_end_time, :thursday_break_start_time, :thursday_break_end_time,
	      :friday_break_start_time, :friday_break_end_time, :saturday_break_start_time, :saturday_break_end_time,
	      :sunday_break_start_time, :sunday_break_end_time, :address, :facebook_url, :twitter_url, :instagram_url, :youtube_url,
	      :linkedin_url, :video_url, :product_knowledge, :specialties, :google_my_business, :claim_approved, :is_claimed,
	      license_informations_attributes: [:id, :user_id, :category_id, :license_number, :state_issued, :expiration_date, :_destroy],
	      business_addresses_attributes: [:id, :user_id, :city, :zip, :price, :url, :_destroy],
	      business_pictures_attributes: [:id, :user_id, :picture, :alt, :description, :_destroy],
	      business_videos_attributes: [:id, :user_id, :video, :alt, :description, :_destroy]
	    ]

	    params.require(:user).permit(accessible)
	  end
end
