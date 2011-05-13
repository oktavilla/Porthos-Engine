class Field < Datum
  key :input_type, String
  key :value

  before_validation :type_cast_value
  validates_presence_of :input_type
  validates_presence_of :value,
                        :if => Proc.new { |d| d.required? && d.input_type != 'boolean' && _root_document.published? }

protected

  def type_cast_value
    case input_type
    when 'boolean'
      self.value = Boolean.to_mongo(value)
    when 'date', 'date_time'
      begin
        self.value = Time.to_mongo(value)
      rescue
        self.value = Time.to_mongo(Chronic.parse(value)) rescue nil
      end
    end
    true
  end

end