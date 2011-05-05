class Datum
  include MongoMapper::EmbeddedDocument
  embedded_in :page

  key :label, String
  key :handle, String
  key :required, Boolean, :default => lambda { false }

  validates_presence_of :label
  validates_presence_of :handle
  validate :uniqueness_of_handle

  before_validation :parameterize_handle

  class << self

    def from_field(field, attrs = {})
      klass = field.datum_type
      attrs = {
        :label => field.label,
        :handle => field.handle,
        :required => field.required?
      }.merge(klass.extract_field_attributes(field)).merge(attrs.to_options)
      klass.new(attrs)
    end

    def extract_field_attributes(field)
      {}
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