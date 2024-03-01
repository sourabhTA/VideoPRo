class BookingsController < ApplicationController

  before_action :no_index , except: [:new]
  # before_action :no_index, only: [:new], if: :user_pending_validation?
  before_action :create_stripe_customer, only: %i[create]
  before_action :titleize_fields, only: %i[create]
  protect_from_forgery with: :null_session

  def withdraw
    begin
      payout = Stripe::Payout.create({amount: (helpers.get_available_account_balance(current_user.stripe_custom_account_id) * 100).to_i,
                                      currency: "usd"}, {stripe_account: current_user.stripe_custom_account_id})
      flash[:notice] = "Your funds have been sent. The direct deposit takes 2 business days." if payout.status == "successded"
    rescue => e
      flash[:alert] = "Stripe: #{e.message}"
    end
    redirect_to bank_accounts_path
  end

  def new
    @archive_user = User.readonly.only_deleted.find_by(slug: params[:slug])

    if @archive_user.present?
      @client = Client.new(booking_attributes: {user_id: @archive_user.id})
      redirect_to error_page_302_path(trade: @archive_user.categories.pluck(:name).last&.downcase, role: @archive_user.role)
    else
      if user.blank?
        # flash[:warning] = "That user account does not exist anymore. Please try another user."
        # redirect_to root_path
        # return
        render file: "#{Rails.root}/public/404.html", layout: false, status: 404
        return
      end
      status = helpers.custom_account_status(user).first
      if status == "pending"
        flash[:warning] = "The user account is not approved yet. Please try another user."
        redirect_to root_path
        return
      end
      @client = Client.new(booking_attributes: {user_id: user.id})
    end
  end

  def fetch_pros
    @users = User.where(category_id: params[:category_id])
    @user = User.find_by(id: params[:user_id]) if params[:user_id].present?
    unless @user.blank?
      @users = [@user] + (@users - [@user])
    end
  end

  def create
    sanitize_date
    @client = Client.new(client_params)
    if @customer
      amount = (total_donation(@client.booking, params["call_time_booked"].to_i) * 100).ceil #( @client.booking.user.rate.fdiv(15) * 100 ).to_f * (params["call_time_booked"].to_i / 60).to_f
      begin
        @charge = Stripe::Charge.create({
                                        amount: amount,
                                        currency: 'usd',
                                        description: 'Initial Booking',
                                        customer: @customer&.id,
                                        capture: false,
                                        transfer_data: { amount: (amount * ( @client.booking.percentage_got_by_user )).ceil,
                                          destination: @client.booking.user.stripe_custom_account_id }
                                      })
      rescue => e
        error_message = e.message
        render json: error_message, status: 400 and return
      end
    end
    if @charge || params[:client][:booking_attributes][:is_booking_fake]
      @client.customer_id = @customer&.id
      @client.booking.amount = @client.booking.user.rate
      @client.booking.fake_booked_time = Booking::FAKE_BOOKING_TIME
      date = client_params[:booking_attributes][:booking_date]
      tod = client_params[:booking_attributes][:booking_time]
      if tod.present? && date.present?
        @client.booking.set_booking_time_in_zone(date: date, tod: tod)
      end

      if @client.valid?
        session = OpenTokClient.create_session(archive_mode: :always, media_mode: :routed)
        @client.booking.archive_id = nil
        @client.booking.session_id = session.session_id
      end

      if @client.save
        flash[:notice] = "Booking has been scheduled!"
        @booking = @client.booking.reload
        @user = @booking.user
        @booking.send_sms_reminders
        @booking.booking_schedule_notification

        @booking.create_charge( params["call_time_booked"], @charge )

        # unless @booking.is_booking_fake
        #   delay_job = @booking.booking_refund_payment
        #   @booking.update(finish_chat_delayjob_id: delay_job.id)
        # end

        BookingMailer.send_videochat_link_to_user(@booking).deliver_later
        BookingMailer.send_videochat_link_to_client(@booking).deliver_later
        BookingMailer.send_videochat_link_to_admins(@booking).deliver_later
        SmsService.send_sms_to_user(@booking) unless @booking.user.phone_number.blank?
        SmsService.send_sms_to_client(@booking) unless @booking.client.phone_number.blank?


        render json: {redirect_url: thankyou_booking_url(@booking)}
      else
        render json: @client.errors.full_messages, status: 401
      end
    end
  rescue Exception => e
    flash[:warning] = e.message
    render json: e.message, status: 401
  end

  def capture_payment
    booking = Booking.find_by(id: params[:id])
    if booking.present?
      start_time = booking.booking_time + booking.booking_minutes.minutes
      call_time = params[:call_time_booked]
      error_message = Booking.any_availability_error?(start_time, call_time.to_i/60, booking.user_id)

      if error_message.present?
        render json: { message: error_message, status: 422 }
      else
        booking.create_charge( call_time ) unless booking.is_booking_fake

        render json: { message: "Time add successfully", total_time: booking.total_captured_time.to_i/60.0, status: 200 }
      end
    else
      render json: { message: "Chat Not Found", status: 200 }
    end
  rescue => e
    render json: { message: e.message, status: 422 }
  end

  def user_avalibility
    booking_date = Date.parse(params[:booking_date])
    booking_time = params[:booking_time]
    user_id = params[:user_id]

    call_minutes = params[:call_seconds].to_i/60

    start_time =
      Time
        .use_zone(params[:time_zone]){ Time.zone.parse("#{booking_time} #{booking_date}")}
        .in_time_zone

    error_message = Booking.any_availability_error?(start_time, call_minutes, user_id)

    render json: { error: error_message, status: "ok"}
  rescue => e
    render json: { error: "Error: #{e.message}", status: "ok" }
  end

  private

  helper_method def time_slots
    @timeslots ||= begin
      booking_date = params[:booking_date].present? ? Date.strptime(params[:booking_date], "%m/%d/%Y") : Date.current
      dow = booking_date.strftime("%A").downcase
      tz = Time.find_zone(params.fetch(:time_zone, user.time_zone))
      user.time_slots_for(dow: dow, booking_date: booking_date, tz: tz)
    end
  end

  helper_method def booking
    @booking ||= Booking.find_by(slug: params[:id])
  end

  helper_method def disable_week_days
    @disable_days ||= begin
      @disable_days = []
      @disable_days << 0 unless @user.is_sunday_on
      @disable_days << 1 unless @user.is_monday_on
      @disable_days << 2 unless @user.is_tuesday_on
      @disable_days << 3 unless @user.is_wednesday_on
      @disable_days << 4 unless @user.is_thursday_on
      @disable_days << 5 unless @user.is_friday_on
      @disable_days << 6 unless @user.is_saturday_on
      @disable_days
    end
  end

  helper_method def user
    @_user ||= User.with_slugs.find_by(slug: params[:slug]) || User.find_by(id: params[:user_id])
  end

  def user_pending_validation?
    user&.pending_stripe_validation?
  end

  def client_params
    params.require(:client).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      booking_attributes: [
        :user_id,
        :booking_date,
        :is_booking_fake,
        :booking_time,
        :city,
        :state,
        :issue,
        :time_zone,
        :agree_with_terms_and_conditions,
        :stripeToken
      ]
    )
  end

  def sanitize_date
    return if params[:client][:booking_attributes][:booking_date].blank?
    params[:client][:booking_attributes][:booking_date] = DateTime.strptime(params[:client][:booking_attributes][:booking_date], "%m/%d/%Y").to_date.strftime("%Y-%m-%d")
  end

  def create_stripe_customer
    fake_booking = params[:client][:booking_attributes]['is_booking_fake']
    return if fake_booking
    @customer = Stripe::Customer.create({
                                         source: client_params[:booking_attributes][:stripeToken],
                                         email: client_params[:email],
                                       })
  rescue => e
    error_message = e.message
    render json: error_message, status: 400 and return
  end

  def total_donation(booking, time)
    amount_per_minute = booking.user.rate_per_minute
    amount_per_second = amount_per_minute.to_f / 60
    (amount_per_second * time)
  end

  def titleize_fields
    params[:client][:first_name] = params[:client][:first_name].titleize
    params[:client][:last_name] = params[:client][:last_name].titleize
  end
end
