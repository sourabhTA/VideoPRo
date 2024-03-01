class PushNotificationModule < ApplicationRecord
  enum user_type: {pro: 0, business: 1, employee: 2, client: 3}
  def when_to_run_push_notification(time_zone)
      run_at_time.in_time_zone(time_zone)
   end

  def send_push_notification_pst
    time_zone = "Pacific Time (US & Canada)"
    if user_type == "client"
      fcm_tokens = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:fcm_token).flatten.uniq
      receivers_email = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:email).flatten.uniq
    elsif slug == "reminder_notification"
      users = User.where("role = ?  and time_zone = ? and avail_update_at IS NULL or avail_update_at < ?", 0, time_zone,
        (Time.now - 24.hours).in_time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
        # actions = ["Yes","No"]
    else
      users = User.where("role = ? and time_zone = ? ", user_type_before_type_cast,
        time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
    end
    return unless fcm_tokens.present?
    obj = PushNotification.new
    obj.fcm_push_notification(
      fcm_tokens,
      title,
      message_body,
      user_type
      # actions
    )
      PushNotificationHistory.create(receivers_email:receivers_email, run_at_time:run_at_time, time_zone: time_zone, title:title, message_body:message_body, user_type:user_type)
    end
    handle_asynchronously :send_push_notification_pst, run_at: proc { |i| i.when_to_run_push_notification("Pacific Time (US & Canada)") }
  def send_push_notification_mst
    time_zone = "Mountain Time (US & Canada)"
    if user_type == "client"
      fcm_tokens = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:fcm_token).flatten.uniq
      receivers_email = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:email).flatten.uniq
    elsif slug == "reminder_notification"
      users = User.where("role = ? and time_zone = ? and avail_update_at IS NULL or avail_update_at < ?", 0, time_zone,
        (Time.now - 24.hours).in_time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
        # actions = ["Yes","No"]
    else
      users = User.where("role = ? and time_zone = ? ", user_type_before_type_cast,
        time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
    end
    return unless fcm_tokens.present?
    obj = PushNotification.new
    obj.fcm_push_notification(
      fcm_tokens,
      title,
      message_body,
      user_type
      # actions
    )
      PushNotificationHistory.create(receivers_email:receivers_email, run_at_time:run_at_time, time_zone: time_zone, title:title, message_body:message_body, user_type:user_type)
    end
    handle_asynchronously :send_push_notification_mst, run_at: proc { |i| i.when_to_run_push_notification("Mountain Time (US & Canada)") }
  def send_push_notification_cst
    time_zone = "Central Time (US & Canada)"
    if user_type == "client"
      fcm_tokens = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:fcm_token).flatten.uniq
      receivers_email = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:email).flatten.uniq
    elsif slug == "reminder_notification"
      users = User.where("role = ?  and time_zone = ? and avail_update_at IS NULL or avail_update_at < ?", 0, time_zone,
        (Time.now - 24.hours).in_time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
    else
      users = User.where("role = ? and time_zone = ? ", user_type_before_type_cast,
        time_zone).where.not(fcm_token: [])
      fcm_tokens = users.map(&:fcm_token).flatten.compact
      receivers_email = users.map(&:email).flatten.compact
    end
    return unless fcm_tokens.present?
    obj = PushNotification.new
    obj.fcm_push_notification(
      fcm_tokens,
      title,
      message_body,
      user_type
      # actions
    )
    PushNotificationHistory.create(receivers_email:receivers_email, run_at_time:run_at_time, time_zone: time_zone, title:title, message_body:message_body, user_type:user_type)
  end
  handle_asynchronously :send_push_notification_cst, run_at: proc { |i| i.when_to_run_push_notification("Central Time (US & Canada)") }
  def send_push_notification_est
    time_zone = "Eastern Time (US & Canada)"
    if user_type == "client"
      fcm_tokens = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:fcm_token).flatten.uniq
      receivers_email = Client.includes(:booking).where.not(fcm_token: []).where(bookings: {time_zone: time_zone}).pluck(:email).flatten.uniq
    elsif slug == "reminder_notification"
    users = User.where("role = ?  and time_zone = ? and avail_update_at IS NULL or avail_update_at < ?", 0, time_zone,
      (Time.now - 24.hours).in_time_zone).where.not(fcm_token: [])
    fcm_tokens = users.map(&:fcm_token).flatten.compact
    receivers_email = users.map(&:email).flatten.compact
  else
    users = User.where("role = ? and time_zone = ? ", user_type_before_type_cast,
      time_zone).where.not(fcm_token: [])
    fcm_tokens = users.map(&:fcm_token).flatten.compact
    receivers_email = users.map(&:email).flatten.compact
  end
  return unless fcm_tokens.present?
  obj = PushNotification.new
  obj.fcm_push_notification(
    fcm_tokens,
    title,
    message_body,
    user_type
    # actions
  )
    PushNotificationHistory.create(receivers_email:receivers_email, run_at_time:run_at_time, time_zone: time_zone, title:title, message_body:message_body, user_type:user_type)
  end
  handle_asynchronously :send_push_notification_est, run_at: proc { |i| i.when_to_run_push_notification("Eastern Time (US & Canada)") }
  end
