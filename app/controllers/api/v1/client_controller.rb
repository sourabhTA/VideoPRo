class Api::V1::ClientController < Api::V1::BaseController

  def client_app_version
    current_version = '1.0.6'
    # current_version = params['current_version'] == '1.0.5' ? '1.0.5' : '1.0.6'
    render json: {
      current_version: current_version,
      android_url: ENV.fetch("android-client"),
      ios_url: ENV.fetch("ios-client"),
      login_string: "To video chat with a pro or business please visit videochatapro.com."
    }
  end

  def client_verify_email
    if params[:email].present?
      email = params[:email].downcase
      client = Client.where(email: email).last || VideoChat.where(email: email).last

      if client.present?
        if client.email == "client-tester@gmail.com"
          return render json: { message: "Tester verified.", status: 200 }
        end

        otp = Otp.find_or_create_by(email: client.email)
        if otp.otp.blank? || ((Time.zone.now - otp.updated_at)/60).to_i >= 1
          otp.update(otp: SecureRandom.random_number(10**6).to_s.rjust(6, '6'))

          GenericMailer.send_client_login_otp(otp).deliver_now
          SmsService.send_otp_to_client(client.phone_number, otp.otp) if client.phone_number.present?

          render json: { message: "OTP Sent successfully.", status: 200 }
        else
          render json: { message: "Please wait for a minute", status: 400 }
        end
      else
        render json: { message: "Email Not Found", status: 400 }
      end
    else
      render json: { message: "Email Required", status: 400 }
    end
  rescue Exception => e
    render json: { error: "#{e.message} ", status: 400 }, status: 400
  end

  # def client_scheduled_chats
  def client_authentication
    begin
      if params[:email].present? && params[:otp].present?
        otp = Otp.find_by(email: params[:email].downcase)
        if otp.present? && otp.otp == params[:otp].to_i
          schedule_chats = VideoChat.where(email: params[:email].downcase, is_call_ended: false)
                                    .in_order.map{ |vc| [
            vc.name, vc.pro_name, vc.session_id, vc.email,
            vc.timings.strftime("%l:%M %p %Z"), vc.timings, vc.watermark
          ] if (!vc.expired_link? && vc.is_call_ended == false) }.compact
          bookings = Booking.where(client_id: Client.where(email: params[:email].downcase).ids )
                            .in_order.map{|x| [
            x.booking_date, x.booking_time.strftime("%l:%M %p %Z"),
            x.client_token, x.client_name, x.pro_name, x.booking_time,
            x.payment_transactions.pluck(:call_time_booked).sum,
            !x.is_booking_fake, x.watermark, x.chat_available,
            (x&.chat_timesheet&.last_time_used || 0), x.expected_end_time.utc
          ] if (!x.expired_link? && x.is_call_ended == false) }.compact

          if schedule_chats.present? || bookings.present?
            render json: { schedule_chats: schedule_chats, booked_chats: bookings, status: 200 }
          else
            render json: {
              schedule_chats: [], booked_chats: [],
              message: 'No Scheduled chat is present.',
              status: 200
            }
          end
        else
          render json: { message: "Email not found or Otp not match.", status: 400 }
        end
      else
        render json: {error: "Email and OTP Required.", status: 400 }
      end
    rescue Exception => e
      render json: {error: "Something went wrong -> #{e.message}." }, status: 401
    end
  end
  def client_fcm_token_update
    begin 
      if params[:email].present? && params[:otp].present?
        otp = Otp.find_by(email: params[:email].downcase)
        client=Client.where(email: params[:email].downcase).last
        if otp.present? && otp.otp == params[:otp].to_i
          client_present = client.fcm_token << params[:fcm_token] unless client.fcm_token.include?(params[:fcm_token])
          Client.where(email: params[:email].downcase).update_all(mobile_login: true)
          if client.save
          render json: {success: "FCM Token Updated Successfully" }
          else
          render json: {error: "Something went wrong" }, status: 401
          end
        end  
      end  
    rescue Exception => e
      render json: {error: "Something went wrong -> #{e.message}." }, status: 401
    end      
  end

  def logout_client
    begin
      if params[:email].present? && params[:otp].present? 
        otp = Otp.find_by(email: params[:email].downcase)
        if otp.present? && otp.otp == params[:otp].to_i
          client = Client.where(email: params[:email].downcase)
          client.update_all(fcm_token: "")
          client.update_all(mobile_login: false)
        end       
      end
    rescue Exception => e
      render json: {error: "Something went wrong -> #{e.message}." }, status: 401
    end 
  end


  def get_client_notification
    begin
      if params['email'].present?
        @notifications = Notification
                           .where(client_email: params['email'])
                           .where(created_at: (Time.now - 24.hours)..Time.now).order(created_at: :desc)
        render json: {notifications: @notifications}

        @notifications.update(is_read: true) if @notifications.exists?(is_read: false)
      else
        render json: {message: 'Client Email not provided', status: 400}
      end
    rescue Exception => e
      render json: {error: "Something went wrong -> #{e.message}." }, status: 401
    end
  end

  def get_booking_summary
    begin
      if params[:id].present?
        @booking = Booking.find(params[:id])
        time_used = Time.at(@booking.time_used).utc.strftime('%H:%M:%S')
        earned = ActionController::Base.helpers.number_to_currency(@booking&.charged_amount) if (@booking.payment_transactions.count > 0)
        review_present = @booking.review.present? || @booking.review&.client_id.present?
        render json: { earned: earned, time_used: time_used, review_present: review_present }
      else
        render json: { message: "Required Booking ID" }
      end
    rescue Exception => e
      render json: { error: "Something went wrong -> #{e.message}" }, status: 408
    end
  end

end
