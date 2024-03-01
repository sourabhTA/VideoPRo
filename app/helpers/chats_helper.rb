module ChatsHelper
  def get_times(chat, call_end_type)
    actual_time_spent = (Time.zone.now.to_f - chat.chat_timesheet.start_time.to_f ).to_i
    if chat.is_a?(VideoChat)
      return Time.zone.now, actual_time_spent
    end

    total_time_booked = chat.payment_transactions.pluck(:call_time_booked).compact.sum
    auto_cut = auto_cut?(call_end_type, actual_time_spent, total_time_booked)

    if auto_cut
      Rails.logger.info "--------Auto cut was considered -----"
      end_time = chat.chat_timesheet.start_time + total_time_booked.seconds
      spent_seconds = total_time_booked
    else
      Rails.logger.info "--------Auto cut was NOT considered -----"
      end_time = Time.zone.now
      spent_seconds = actual_time_spent
    end
    return end_time, spent_seconds
  end

  def auto_cut?(auto_cut_param, actual_time_spent, total_time_booked)
    difference = actual_time_spent - total_time_booked
    auto_cut_param == "autocut" && difference.abs < 20
  end
end
