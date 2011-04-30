require 'chronic'
class Datum
  include MongoMapper::EmbeddedDocument
  embedded_in :page

  key :label, String
  key :handle, String
  key :input_type, String
  key :required, Boolean, :default => lambda { false }
  key :value

  validates_presence_of :label
  validates_presence_of :input_type
  validates_presence_of :handle
  validate :uniqueness_of_handle
  validates_presence_of :value,
                        :if => Proc.new { |d| d.required? && d.input_type != 'boolean' && page.published? }

  before_validation :type_cast_value
  before_validation :parameterize_handle

  class << self
    def from_field(field, attrs = {})
      new(attrs.to_options.reverse_merge({
        :label => field.label,
        :handle => field.handle,
        :input_type => field.class.model_name.gsub(/Field/, '').underscore,
        :required => field.required
      }))
    end
  end

  def type_cast_value
    case self.input_type
    when 'boolean'
      self.value = Boolean.to_mongo(value)
    when 'date'
    when 'date_time'
      if value.is_a?(Hash)
        attrs = value.to_options
        self.value = "#{attrs[:year]}-#{attrs[:month]}-#{attrs[:day]} #{attrs[:hour]}:#{attrs[:minute]}"
      end
      if value.acts_like?(:string)
        begin
          self.value = Time.parse(value).localtime
        rescue
          self.value = Chronic.parse(value).localtime rescue nil
        end
      end
    end
  end

protected

  def uniqueness_of_handle
    if page.data.detect { |d| d.id != self.id && d.handle == self.handle }
      errors.add(:handle, :taken)
    end if page
  end

  def parameterize_handle
    self.handle = handle.parameterize('_') if handle.present?
  end

end