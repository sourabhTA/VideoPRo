class ChatTimesheet < ApplicationRecord
  belongs_to :chat, polymorphic: true
  has_many :chat_timeslots, dependent: :destroy

  def time_used
    return "00:00:00" if end_time.blank? || start_time.blank?
    Time.at(end_time - start_time).utc.strftime("%H:%M:%S")
  end

  def total_time_used
    t_used = chat.chat_timesheet&.chat_timeslots&.pluck(:time_used)&.compact&.sum || 0
    Time.at(t_used).utc.strftime("%H:%M:%S")
  end

  def last_time_used
    chat_timeslots&.pluck(:time_used)&.compact&.sum || 0
  end

  def set_end(end_time)
    self.update(end_time: end_time)
  end

  def self.set_start(chat:, pro:)
    key = pro ? :pro_start : :client_start

    sql = sanitize_sql_array([<<~SQL.squish, chat.id, chat.class.name])
      insert into chat_timesheets (#{key}, chat_id, chat_type)
      values (now(), ?, ?)
      on conflict (chat_id, chat_type)
      do update
        set #{key} = now()
        where chat_timesheets.#{key} is null;
    SQL
    connection.execute(sql)

    chat.chat_timesheet
  end

  def start_time
    if client_start.present? && pro_start.present?
      [client_start, pro_start].max
    end
  end

  def start_timeslots(pro=false)
    chat_timeslots.create(start_time: Time.current) if pro
  end

end
