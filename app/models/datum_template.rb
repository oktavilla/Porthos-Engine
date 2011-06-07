class DatumTemplate
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  validates_presence_of :label

  # after_destroy :propagate_removal

  class << self
    def from_type(type, attributes = {})
      case type
      when "FieldTemplate"
        if attributes['input_type'] == 'string'
          StringFieldTemplate.new(attributes)
        else
          FieldTemplate.new(attributes)
        end
      else
        type.constantize.new(attributes)
      end
    end
  end

  def to_datum
    datum_class.constantize.from_template(self)
  end

  def datum_class
    (self.class.ancestors - self.class.included_modules).collect do |klass|
      klass.to_s.gsub('Template', '')
    end.detect do |klass_name|
      begin
        defined?(klass_name.constantize)
      rescue NameError
        false
      end
    end
  end

  def shared_attributes
    attributes.clone.except(:_id, :_type).inject({}) do |hash, entry|
      key, value = entry
      hash[key] = value.duplicable? ? value.clone : value
      hash
    end
  end

private

  def propagate_self
    nil # overwrite in subclasses
  end

  def propagate_removal
    pages = MongoMapper.database.collection('pages')
    pages.update({
      'page_template_id' => self._root_document.id
    }, {
      '$pull' => {
        'data' => { 'handle' => self.handle }
      }
    }, :multi => false, :safe => true)
  end

end