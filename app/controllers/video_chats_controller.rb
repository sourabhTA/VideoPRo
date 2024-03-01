class VideoChatsController < AuthenticatedController
  include ScheduledChatsHelper

  before_action do
    check_permissions_for(:business, :employee)
  end
  before_action :check_required_settings, only: [:index, :create, :destroy], if: proc { current_user.business? }

  def send_email
    if request.post?
      BookingMailer.send_videochat_link_from_business(video_chat).deliver_now
      BookingMailer.send_videochat_link_to_sender(video_chat).deliver_now
      flash[:notice] = "Email Sent successfully!"
      redirect_to video_chats_path
    end
  end

  def create
    to = employees.find_by(id: video_chat_params[:to_id])
    video_chat.to_id = to&.id
    video_chat.from_id = current_user.id
    video_chat.email = to&.email unless video_chat.email.present?
    video_chat.business_id = current_user.business? ? current_user.id : current_user.business_id
    video_chat.booked_time = VideoChat::FAKE_BOOKING_TIME
    if video_chat_params[:time_zone]
      video_chat.set_timings_time_in_zone(
        date: video_chat_params[:timings],
        tz: video_chat_params[:time_zone]
      )
    end

    respond_to do |format|
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

        format.html { redirect_to video_chats_path, notice: "Video chat was successfully created." }
        format.json { render :show, status: :created, location: video_chat }
      else
        format.html { render :new, status: 422 }
        format.json { render json: video_chat.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    video_chat.destroy

    respond_to do |format|
      format.html { redirect_to video_chats_url, notice: "Video chat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  helper_method :video_chat, :video_chats, :employees

  private

  def employees
    @employees ||= current_user.all_business_users
  end

  def video_chats
    @video_chats ||= current_user.video_chats.includes(:business, :receiver, :sender).order(updated_at: :desc)
  end

  def video_chat
    @video_chat ||= begin
      chat = if params[:id].present?
        VideoChat.find_by(session_id: params[:id])
      else
        current_user.video_chats.new(
          timings: Time.find_zone(current_user.time_zone).now
        )
      end
      chat.attributes = video_chat_params if params[:video_chat].present?
      chat
    end
  end

  def opentok_data
    token = OpenTokClient.generate_token(video_chat.session_id)
    {sessionId: video_chat.session_id, apiKey: ENV.fetch("opentok_api_key"), token: token}
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
