class Api::V1::ChatsController < Api::V1::BaseController
  before_action :user_authenticate, only: [:start, :start_clock]
  before_action :verify_chat_time, only: [:start, :client_start]
  include ChatsHelper

  def start
    chat_start
  end

  def client_start
    chat_start
  end

  def start_clock
    clock
  end

  def client_start_clock
    clock
  end

  def sync_clock
    if chat&.payments_made?
      render json: { error: "You already had a call session on this booking." }, status: 422
    elsif chat&.minutes_available?
      render json: { start_time: chat.chat_timesheet.start_time }
    else
      render json: { error: "Either you are on free plan or no minutes available." }, status: 422
    end
  end

  def end_chat
    if chat.present?
      if chat.is_a?(AdminVideoChat)
        render json: {message: "Thank you for using Video Chat A Pro!" }
      end

      if chat.chat_timesheet.present? && chat.chat_timesheet.start_time.present?

        unless chat.is_call_ended?
          end_time, spent_seconds = get_times(chat, params[:endCall_type])

          if spent_seconds > 0
            @error = chat.end_call(spent_seconds, end_time, params[:connection_Id])

            if @error.present?
              render json: { error: error }, status: 401
            else
              render json: { message: "Call is Completed." }
            end
            Rails.logger.info "------------Call End from Phone -------BY--- #{ my_name }"
          else
            render json: { message: "Time not count." }, status: 422
          end
        else
          render json: { message: "Call is Already Completed." }
          Rails.logger.info chat.inspect
          Rails.logger.info chat.chat_timesheet.inspect
        end
      else
        render json: { message: "Call not Start." }
      end
    else
      render json: { message: "Chat not Present." }
    end
  rescue => e
    render json: { message: "Error: #{e.message}." }
  end

  def new_review
    @new_review ||= chat&.reviews.find_or_initialize_by(reviewer_name: name_for_review, user_id: pro? ? nil : chat&.review_for_id)
  end

  def add_review
    begin
      if params[:id].present?
        new_review.rating = params[:score]
        new_review.comment = params[:review]
        new_review.reviewer_name = name_for_review
        new_review.client_id = params["type"] == 'booking' ? chat.client_id : nil
        if new_review.save
          render json: { message: "Review Created." }
        end
      end
    rescue Exception => e
      render json: { error: e.message }, status: 422
    end
  end

  def get_review

    if chat.reviews
      
      review = chat.reviews.where.not(user_id: nil).first
      time_used = chat&.chat_timesheet&.last_time_used || 0
      end_time = chat.is_a?(Booking) ? chat.expected_end_time.utc : chat.expected_end_time.utc
      render json: {
        review: review,
        time_used: time_used,
        # total_chat_time: chat.total_captured_time,
        end_time: end_time,
        message: "Get Review."
      }
    end
  rescue => e
    Rails.logger.warn "Error -> #{e.inspect}"
    render json: { error: e.message }, status: 422
  end

  def add_chat_time
    begin
      if params[:id].present? && params[:call_time_booked].present?
        if chat.present?
          start_time = chat.booking_time + chat.booking_minutes.minutes
          call_time = params[:call_time_booked]
          error_message = Booking.any_availability_error?(start_time, call_time.to_i/60, chat.user_id)
          if error_message.present?
            render json: { message: error_message, status: 422 }
          else
            if chat.create_charge( call_time )
              render json: {
                message: "Time added successfully.",
                chat_time: chat.total_captured_time,
                end_time: chat.expected_end_time.utc,
                status: 200
              }
            else
              render json: { message: "Could not add time.", status: 422 }
            end
          end
        else
          render json: { message: "Chat Not Found", status: 404 }
        end
      else
        render json: { message: "Booking ID & Booking Time Required", status: 422 }
      end
    rescue Exception => e
      render json: { message: e.message, status: 422 }
    end
  end

  def get_chat_time
    if params[:id].present?
      if chat.present?
        render json: {
          chat_time: chat.total_captured_time,
          end_time: chat.expected_end_time.utc
        }
      else
        render json: { message: "Chat Not Found" }
      end
    else
      render json: { message: "Chat Id required" }
    end
  rescue Exception => e
    render json: { error: e.message, status: 422 }
  end

  private

  def chat_start
    if chat.payments_made?
      render json: { message: "You already had a call session on this booking.", type: "completed" }
    elsif chat.minutes_available?
      render json: opentok_data
    else
      render json: { message: "Either you are on free plan or no minutes available." }
    end
  end

  def clock
    if chat.payments_made?
      render json: { error: "You already had a call session on this booking." }, status: 422
    elsif chat.minutes_available?
      timesheet = ChatTimesheet.set_start(chat: chat, pro: pro?)

      timeslot = timesheet.start_timeslots(pro?)

      chat.update(connection_id: params[:connectionId])
      chat.on_StartClock_delayJob(timesheet) if chat.chat_timesheet.start_time.present?

      Rails.logger.info "Call start from Phone --========= #{ timesheet.inspect } === Chat = #{ chat.inspect }"
      t_used = chat&.chat_timesheet&.chat_timeslots&.pluck(:time_used)&.compact&.sum || 0
      render json: { start_time: timesheet.start_time, time_used: t_used, end_time: chat.is_a?(Booking) ? chat.expected_end_time.utc : chat.expected_end_time.utc }
    else
      render json: { error: "Either you are on free plan or no minutes available." }, status: 422
    end
  end

  def verify_chat_time
    if chat&.early_link?
      render json: { message: "Your Time is not started yet.", type: "earlyLink", delay_time: (chat.chat_time - Time.current) / 1.minute }
    elsif chat&.expired_link?
      render json: { message: "This Video Chat link is expired, please contact Support.", type: "expiredLink" }
    end
  end

  def opentok_data
    if chat.init_session_id.blank?
      init_session = OpenTokClient.create_session(archive_mode: :always, media_mode: :routed)
      chat.update(init_session_id: init_session.session_id)
    end
    chat.reload
    token = OpenTokClient.generate_token(chat.init_session_id, { data: my_name })
    {
      sessionId: chat.init_session_id,
      clockSessionId: chat.session_id,
      token: token,
      type: "tokenCreated"
    }
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

                if params[:type] == 'booking' && params[:id_type] != 'token'
                  chat = Booking.find_by(id: params[:id])
                end
                chat
              end
  end

  def pro?
    case chat
    when VideoChat
      @current_user&.id == chat.from_id
    else
      chat.professional_token == params[:id]
    end
  end

  def name_for_review
    anonymous_user? ? params['email'].downcase : my_name
  end

  def anonymous_user?
    my_name.include?("@") || my_name.remove(/\D/).size >= 7
  end

  def my_name
    pro? ? chat.pro_name : "#{chat.client_name} client"
  end

end
