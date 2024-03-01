FactoryBot.define do
  factory :chat_timeslot do
    client_start { "2022-05-16 16:32:20" }
    pro_start { "2022-05-16 16:32:20" }
    end_time { "2022-05-16 16:32:20" }
    timesheet_id { 1 }
    chat_timesheet { nil }
  end
end
