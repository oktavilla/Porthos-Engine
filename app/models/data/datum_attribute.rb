class DatumAttribute < Datum
  key :input_type, String
  key :value

  before_validation :type_cast_value
  validates_presence_of :input_type
  validates_presence_of :value,
                        :if => Proc.new { |d| d.required? && d.input_type != 'boolean' && page.published? }

protected

  def type_cast_value
    case self.input_type
    when 'boolean'
      self.value = Boolean.to_mongo(value)
    when 'date'
    when 'date_time'
      if value.is_a?(Hash)
        attrs = value.to_options
        self.value = Time.to_mongo("#{attrs[:year]}-#{attrs[:month]}-#{attrs[:day]} #{attrs[:hour]}:#{attrs[:minute]}")
      elsif value.acts_like?(:string)
        begin
          self.value = Time.to_mongo(value)
        rescue
          self.value = Time.to_mongo(Chronic.parse(value)) rescue nil
        end
      end
    end
    true
  end

  def self.extract_field_attributes(field)
    { :input_type => field.class.model_name.gsub(/Field/, '').underscore }
  end

end