module Pages
  class VideoChatIndexPage < PageObject
    def visit_page
      visit video_chats_path
      self
    end

    def on_page?
      has_selector? "h3", text: "In House Chat"
    end

    def press_send_video_chat
      click_on "Send Video Chat"
      self
    end

    def video_chats_table
      headers = all("th").map(&:text)
      all("tbody tr").map { |tr|
        row_values = tr.all("td").map { |value| value.text.to_s.strip }
        Hash[headers.zip row_values].select { |k, _| k.present? }
      }
    end

    def has_created_notice?
      has_notice? "Video chat was successfully created."
    end

    def has_updated_notice?
      has_notice? "Account Updated"
    end

    def has_deleted_notice?
      has_notice? "Account Deleted"
    end

    def has_missing_recipient_error?
      has_selector? "li", text: "Receiver missing. Please enter an email address or select an employee"
    end
  end
end
