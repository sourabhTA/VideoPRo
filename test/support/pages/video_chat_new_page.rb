module Pages
  class VideoChatNewPage < PageObject
    def visit_page
      visit new_video_chat_path
      self
    end

    def on_page?
      has_selector? "h3", text: "Send New In House Chat Link"
    end

    def fill_in_chat_time(time)
      fill_in :timings_datetimepicker, with: time
      self
    end

    def select_employee(employee)
      select employee, from: :video_chat_to_id
      self
    end

    def select_time_zone(time_zone)
      select time_zone, from: :video_chat_time_zone
      self
    end

    def fill_in_email(email)
      fill_in :video_chat_email, with: email
      self
    end

    def fill_in_name(name)
      fill_in :video_chat_name, with: name
      self
    end

    def fill_in_phone_number(phone_number)
      fill_in :video_chat_phone_number, with: phone_number
      self
    end

    def fill_in_subject(subject)
      fill_in :video_chat_subject, with: subject
      self
    end

    def fill_in_body(body)
      fill_in :video_chat_body, with: body
      self
    end

    def press_send
      click_on "Send Chat Link"
      self
    end
  end
end
