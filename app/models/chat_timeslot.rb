class ChatTimeslot < ApplicationRecord
  belongs_to :chat_timesheet

  def set_end(end_time)
    expected_time = self.chat_timesheet.chat.expected_end_time

    end_time = expected_time if (end_time > expected_time)

    time_used = (end_time - self.start_time).round
    self.update(end_time: end_time, time_used: time_used) if self.end_time.nil?
  end
end
