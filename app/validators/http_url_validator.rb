class HttpUrlValidator < ActiveModel::EachValidator
  def self.compliant?(value)
    value =~ /\A(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([\/\w.-]*)*\/?\Z/i
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    unless value.present? && self.class.compliant?(value)
      record.errors.add(attribute, "is not a valid URL")
    end
  end
end
