class Api::V1::EmployeeController < Api::V1::BaseController
  before_action :user_authenticate, only: [:create_user_employee, :fetch_employees,
    :update_employee_notifications, :employee_video_chat, :create_video_chat ]

  def create_user_employee
    begin
      employee = User.new(employee_params)
      employee.password_confirmation = employee_params[:password]
      employee.role = "employee"
      employee.business_id = @current_user.id
      employee.agree_to_terms_and_service = true
      employee.skip_confirmation!
      if employee.save!
        employee.confirm
        GenericMailer.added_into_business(employee_params).deliver

        render json: { message: "Employee created successfully!", user_employees: @current_user&.employees&.select(:email, :name, :phone_number, :all_notifications, :id, :slug) }
      else
        render json: { error: "Employee is invalid!" }, status: 401
      end
    rescue Exception => e
      render json: { error: "#{e.message}" }, status: :not_found
    end
  end

  def fetch_employees
    begin
      employees = @current_user&.all_business_users&.where.not(email: @current_user.email).select(:email, :name, :phone_number, :all_notifications, :id, :slug)
      subscribed = @current_user&.plan.present?
      render json: { user_employees: employees, subscribed: subscribed}
    rescue Exception => e
      render json: { error: "Something went wrong #{e.message}" }, status: 400
    end
  end

  def update_employee_notifications
    begin
      employee = @current_user.employees.find_by_slug(params[:slug])
      employee.update(all_notifications: !employee.all_notifications)
      render json: { user_employees: @current_user&.employees&.created_desc&.select(:email, :name, :phone_number, :all_notifications, :id, :slug) }
    rescue Exception => e
      render json: { error: "Something went wrong" }, status: 401
    end
  end

  def create_video_chat
    begin
      to = employees.find_by(id: video_chat_params[:to_id])
      video_chat.to_id = to&.id

      if to
        time_zone = video_chat_params[:time_zone].present? ? video_chat_params[:time_zone] : to.time_zone
        video_chat.set_timings_time_in_zone(
          date: ( video_chat_params[:timings].present? ? video_chat_params[:timings] : Time.now.strftime("%m-%d-%Y %I:%M %p") ),
          tz: ( video_chat_params[:timings].present? ? time_zone : Time.zone.name )
        )
        video_chat.time_zone = time_zone
        video_chat.phone_number = to.phone_number
        video_chat.email = to.email
        video_chat.name = to&.name
      else
        if video_chat_params[:time_zone]
          video_chat.set_timings_time_in_zone(
            date: video_chat_params[:timings],
            tz: video_chat_params[:time_zone]
          )
        end
      end
      video_chat.booked_time = VideoChat::FAKE_BOOKING_TIME

      video_chat.from_id = @current_user.id
      video_chat.business_id = @current_user.business? ? @current_user.id : @current_user.business_id

      if video_chat.save
        opentok_session = OpenTokClient.create_session(archive_mode: :always, media_mode: :routed)
        video_chat.update(session_id: opentok_session.session_id)

        BookingMailer.send_videochat_link_from_business(video_chat).deliver_later
        SmsService.send_sms_from_business(video_chat)
        video_chat.create_delay_job_end_call()

        if (video_chat.timings - Time.zone.now).to_i > 300
          video_chat.schedule_reminder
          video_chat.schedule_notification
        end

        render json: { message: "Video chat created successfully and notified to the user through email and SMS." }
      else
        render json: { error: "Something went wrong." }, status: 400
      end
    rescue Exception => e
      render json: { error: "Something went wrong -> #{e.message}" }, status: 400
    end
  end

  private

    def employee_params
      params.require(:user).permit(:name, :email, :password, :phone_number)
    end

    def employees
      @employees ||= @current_user.all_business_users
    end

    def video_chat
      @video_chat ||= begin
        chat = if params[:id].present?
          VideoChat.find_by(session_id: params[:id])
        else
          @current_user.video_chats.new(
            timings: Time.find_zone(@current_user.time_zone).now
          )
        end
        chat.attributes = video_chat_params if params[:video_chat].present?
        chat
      end
    end

    def video_chat_params
      params.require(:video_chat).permit(
        :name,
        :email,
        :subject,
        :body,
        :phone_number,
        :to_id,
        :timings,
        :time_zone
      )
    end

end
