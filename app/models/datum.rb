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
  validates_inclusion_of :value,
                         :in => [true, false],
                         :if => Proc.new { |d| d.required? && d.input_type == 'boolean' && d.page.published? }

  before_validation :parameterize_handle
  before_validation :type_cast_value

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

protected

  def type_cast_value
    if value.present?
      case self.input_type
      when 'boolean'
        self.value = Boolean.to_mongo(value)
        true
      when 'date'
      when 'date_time'
        if !value.acts_like?(:time) && !value.acts_like?(:date)
          self.value = Chronic.parse(value)
        end
      end
    end
  end

  def uniqueness_of_handle
    if page.data.detect { |d| d.id != self.id && d.handle == self.handle }
      errors.add(:handle, :taken)
    end
  end

  def parameterize_handle
    self.handle = handle.parameterize('_') if handle.present?
  end

end