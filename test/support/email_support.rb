module EmailSupport
  def find_mail_with_subject(subject)
    find_last_email { |mail| mail.subject.include? subject }
  end
  alias_method :find_email_with_subject, :find_mail_with_subject

  def find_last_email_to(address)
    find_last_email { |mail| mail.to.include? address }
  end

  def find_all_emails_to(address:)
    find_all_emails.select { |mail| mail.to.map(&:downcase).include?(address.downcase) }
  end

  def find_all_emails
    ActionMailer::Base.deliveries.map { |email| email.extend(MessageHelper) }
  end

  private

  def find_last_email(&block)
    find_all_emails.reverse.detect(&block)
  end

  module MessageHelper
    def links
      html.css("a").map { |anchor| anchor["href"] }
    end

    def html
      Nokogiri::HTML(html_body)
    end

    def text
      text_part.body.to_s
    end

    private

    def html_body
      (html_part.try(:body) || body).to_s
    end
  end
end
