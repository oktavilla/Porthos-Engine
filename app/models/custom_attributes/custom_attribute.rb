class CustomAttribute

  include MongoMapper::EmbeddedDocument

  class_inheritable_accessor :value_attribute

  key :_type, String
  key :field_id, Integer
  key :handle, String

  def field
    Field.find(field_id)
  end

  def field=(_field)
    field_id = _field.id
  end

  before_validation :parameterize_handle

  def value=(value)
    write_attribute(self.value_attribute, value)
  end

  def value
    @value = read_attribute(self.value_attribute)
    @value.present? && @value.acts_like?(:string) ? @value.html_safe : @value
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize if handle.present?
  end

end