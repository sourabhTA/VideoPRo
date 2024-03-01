class ChatsController < ApplicationController
  before_action :authenticate_user!, only: %i[download]
  before_action :verify_chat, except: :tokbox_callback
  skip_before_action :verify_authenticity_token, only: :tokbox_callback
  before_action :verify_chat_time, only: %i[start]
  before_action :verify_chat_expired, only: %i[show]
  before_action :get_chat_detail, only: [:start_clock, :sync_clock]
  include ChatsHelper

  def download
    unless can_download?(current_user)
      flash[:alert] = "You are not authorized. This incident will be reported."
      redirect_to scheduled_chats_path
      return
    end

    download_url = SignedUrlAdapter.new(archive_id: chat.archive_id, download_name: chat.download_name).signed_url
    if download_url
      redirect_to download_url
    else
      flash[:alert] = "We could not find that archive."
      redirect_to scheduled_chats_path
    end
  end

  def show
    if professional_logged_out?
      flash[:warning] = "You must login to join this video chat."

      session[:redirect_chat_id] = chat.professional_token

      if chat.is_a?(AdminVideoChat)
        stored_location_for(AdminUser.new)
        redirect_to new_admin_user_session_path
      else
        stored_location_for(User.new)
        redirect_to new_user_session_path
      end
      return
    end

    if chat.payments_made?
      flash[:alert] = "You already had a call session on this booking."
      redirect_to root_path
      return
    end

    if !chat.minutes_available?
      flash[:warning] = "Either you are on free plan or no minutes available."
      redirect_to root_path
    end
  end

  def sync_clock
    if professional_logged_out?
      render json: {error: "You must login to join this video chat."}, status: 422
    elsif chat.payments_made?
      render json: {error: "You already had a call session on this booking."}, status: 422
    elsif chat.minutes_available?
      timesheet = ChatTimesheet.set_start( chat: chat, pro: pro? )

      clock_timer = @booked_time
      unless chat.is_a?(AdminVideoChat)
        if chat.is_a?(Booking) && !chat.is_booking_fake?
            clock_timer = (chat.booking_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
            elsif chat.is_a?(Booking) && chat.is_booking_fake?
            clock_timer = (chat.booking_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
          else
            clock_timer = (chat.recipient_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
        end
      end  
      render json: { start_time: chat.chat_timesheet.start_time,
                      time_used: chat.chat_timesheet.last_time_used,
                      free_charge: @free_charge,
                      booked_time: clock_timer,
                      chat_type: chat.class.name,
                      user_type: @user_type,
                      total_time: chat.is_a?(Booking) ? chat.total_captured_time.to_i/60.0 : 0
                    }
    else
      render json: {error: "Either you are on free plan or no minutes available."}, status: 422
    end
  end

  def start_clock
    if professional_logged_out?
      render json: { error: "You must login to join this video chat."}, status: 422
    elsif chat.payments_made?
      render json: { error: "You already had a call session on this booking."}, status: 422
    elsif chat.minutes_available?
      timesheet = ChatTimesheet.set_start( chat: chat, pro: pro? )

      clock_timer = @booked_time
        timeslot = timesheet.start_timeslots(pro?)
        chat.update(connection_id: params[:connectionId])
        if chat.is_a?(Booking) && !chat.is_booking_fake?
          clock_timer = (chat.booking_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
        elsif chat.is_a?(Booking) && chat.is_booking_fake?
          clock_timer = (chat.booking_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
        else
           clock_timer = (chat.recipient_time.advance(seconds: chat.total_captured_time) - timesheet.start_time).round
        # end
        # chat.on_StartClock_delayJob(timesheet) if chat.chat_timesheet.start_time.present?
       end

      Rails.logger.info "Call start from Web --========= #{ timesheet.inspect } === Chat = #{ chat.inspect }"
      render json: { start_time: timesheet.start_time,
                      time_used: chat.chat_timesheet.last_time_used,
                      free_charge: @free_charge,
                      booked_time: clock_timer,
                      chat_type: chat.class.name,
                      user_type: @user_type
                    }
    else
      Rails.logger.info "---- ========== Either you are on free plan or no minutes available. ------------ =========== "
      render json: {error: "Either you are on free plan or no minutes available.", status: 422 }
    end
  rescue => e
    Rails.logger.info "---- ========== #{e.inspect} ------------ =========== "
    render json: {error: "Error: #{e.inspect}", status: 422 }
  end

  def start
    if professional_logged_out?
      render json: { error: "You must login to join this video chat." }, status: 422
    elsif chat.payments_made?
      render json: { error: "You already had a call session on this booking." }, status: 422
    elsif chat.minutes_available?
      render json: opentok_data
    else
      render json: { error: "Either you are on free plan or no minutes available." }, status: 422
    end
  end

  def end
    if chat.is_a?(AdminVideoChat)
      redirect_to root_path, notice: "Thank you for using Video Chat A Pro!"
      return
    end

    if chat.chat_timesheet.present? && chat.chat_timesheet.start_time.present?
      unless chat.is_call_ended?

        end_time, spent_seconds = get_times(chat, params[:endCall_type])
        if spent_seconds > 0
          @error = chat.end_call(spent_seconds, end_time, params[:connection_id])

          if @error.present?
            flash[:alert] = @error
          end
          Rails.logger.info "------------Call End from Web---BY-- #{ my_name }----Chat----- #{chat.inspect}"
        else
          redirect_to chat_path(params[:id])
        end

        Rails.logger.info chat.inspect
        Rails.logger.info chat.chat_timesheet.inspect
      end
    else
      redirect_to chat_path(params[:id])
    end
  end

  def get_total_cost
    if chat.present?
      render json: { charged_amount: chat.charged_amount, status: 200 }
    else
      render json: { message: "Chat not present.", status: 404 }
    end
  rescue => e
    render json: { message: "Something went wrong."},  status: 500
  end

  def review
    new_review.rating = params[:score]
    new_review.comment = params.dig(:review, :comment)
    new_review.reviewer_name = name_for_review
    if new_review.save

      redirect_to root_path, notice: "Thank you for leaving a review!"
      return
    end

    render :end
  end

  def tokbox_callback
    not_found && return if params[:partnerId].to_s != OpenTokClient.api_key.to_s

    archive = Booking
      .where(archive_id: nil)
      .find_by(init_session_id: params[:sessionId]) ||
      Booking
        .where(archive_id: nil)
        .find_by(session_id: params[:sessionId]) ||
      VideoChat
        .where(archive_id: nil)
        .find_by(init_session_id: params[:sessionId]) ||
      VideoChat
        .where(archive_id: nil)
        .find_by(session_id: params[:sessionId])

    if archive.present? && params[:status] == "uploaded"
      archive.update(archive_id: params[:id])
    end

    render json: {}, status: 200
  end

  helper_method :error,
    :new_review,
    :name_under_review,
    :my_name,
    :waiting_for_name,
    :chat,
    :pro?,
    :anonymous_user?

  private

  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end

  def anonymous_user?
    my_name.include?("@") || my_name.remove(/\D/).size >= 7
  end

  def new_review
    @new_review ||= chat.reviews.find_or_initialize_by(reviewer_name: name_for_review, user_id: pro? ? nil : chat.review_for_id)
  end

  attr_reader :error

  def opentok_data
    if chat.init_session_id.blank?
      init_session = OpenTokClient.create_session(archive_mode: :always, media_mode: :routed)
      chat.update(init_session_id: init_session.session_id)
    end
    chat.reload
    token = OpenTokClient.generate_token(chat.init_session_id, {data: my_name})
    {
      sessionId: chat.init_session_id,
      apiKey: OpenTokClient.api_key,
      token: token
    }
  end

  def verify_chat
    if chat.blank?
      redirect_to root_path, alert: "You are trying to access the wrong page, please contact support."
    end
  end

  def verify_chat_expired
    if chat.expired_link?
      flash[:alert] = "This Video Chat link is expired, please contact Support."
      redirect_to root_path
    end
  end

  def verify_chat_time
    if chat.early_link?
      respond_to do |f|
        f.html {
          flash[:alert] = "Your Time is not started yet."
          redirect_to root_path
        }
        f.json { render json: {error: "Your Time is not started yet."}, status: 422 }
      end
    elsif chat.expired_link?
      flash[:alert] = "This Video Chat link is expired, please contact Support."
      redirect_to root_path
    end
  end

  def chat
    @chat ||= begin
      chat = VideoChat.includes(:sender).find_by(session_id: params[:id])
      # Terrible attempt to see if :id is a uuid
      if chat.blank? && params[:id].remove(/[^-]/).size == 4
        where = ["client_token = :token or professional_token = :token", token: params[:id]]
        chat = Booking.includes(:user, :client).where(where).first ||
          AdminVideoChat.where(where).first
      end

      chat
    end
  end

  def pro?
    case chat
    when VideoChat
      current_user&.id == chat.from_id
    else
      chat.professional_token == params[:id]
    end
  end

  def waiting_for_name
    pro? ? chat.client_name : chat.pro_name
  end

  def my_name
    pro? ? chat.pro_name : "#{chat.client_name} client"
  end

  def name_under_review
    pro? ? "Video Chat A Pro" : chat.pro_name
  end

  def name_for_review
    anonymous_user? ? params.dig(:review, :reviewer_name) : my_name
  end

  def professional_logged_out?
    case chat
    when AdminVideoChat
      pro? && current_admin_user.blank?
    when Booking
      pro? && chat.user_id != current_user&.id
    when VideoChat
      # No way to know
      false
    end
  end

  def can_download?(user)
    id_to_check = [user.business_id, user.id].compact.first
    id_to_check == chat.user_id
  end

  def get_chat_detail
    @free_charge = ( chat.class.name == "Booking" && chat.is_booking_fake )
    @booked_time = ( chat.class.name == "Booking" && chat.payment_transactions.present? ) ? 
                    chat.payment_transactions.pluck(:call_time_booked).sum : 0

    @user_type = ( chat.client_token == params[:id] ? "Client" : "User" ) if chat.class.name == "Booking"
  end

end
