class Field
  include MongoMapper::EmbeddedDocument
  embedded_in :field_set

  key :label, String
  key :handle, String
  key :required, Boolean, :default => lambda { false }
  key :instructions, String

  validates :label,
            :presence => true
  validates :handle,
            :presence => true

  validate :uniqueness_of_handle
  validate :not_a_reserved_handle

  before_validation :parameterize_handle

  cattr_reader :types
  @@types = [
    StringField,
    DateTimeField,
    BooleanField
  ].to_set

protected

  def parameterize_handle
    self.handle = handle.parameterize('_') if handle.present?
  end

  def uniqueness_of_handle
    if field_set.fields.detect { |f| f.id != self.id && f.handle == self.handle }
      errors.add(:handle, :taken)
    end
  end

  def not_a_reserved_handle
    errors.add(:handle, :reserved) if handle.present? && Page.new.respond_to?(handle)
  end

end