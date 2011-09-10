require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      mail = Mail::Address.new(value)
      valid_email = (mail.domain.present? && mail.domain.include?('.') && mail.address == value)
    rescue Mail::Field::ParseError => e
      valid_email = false
    end
    unless valid_email
      record.errors.add attribute, (options[:message] || :invalid_email)
    end
  end
end
