class AdminVideoChat < ApplicationRecord
  include Chat
  has_one :chat_timesheet, as: :chat

  after_create :update_tokbox_session

  def watermark
    "watermark.png"
  end

  def update_tokbox_session
    if session_id.blank?
      session = OpenTokClient.create_session(archive_mode: :always, media_mode: :routed)
      update(session_id: session.session_id)
    end
  end

  def chat_time
    Time.current
  end

  def minutes_available?
    true
  end

  def early_link?
    false
  end

  def expired_link?
    false
  end

  def payments_made?
    false
  end

  def pro_name
    "Video Chat A Pro"
  end

  def client_name
    name
  end

  def end_call(seconds)
    chat_timesheet.set_end
  end
end
