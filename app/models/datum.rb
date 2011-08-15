class Datum
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods
  key :datum_template_id, ObjectId
  key :active, Boolean, :default => lambda { true }

  one :datum_template

  def root_embedded_document
    @root_embedded_document ||= _parent_document == _root_document ? self : _parent_document.try(:root_embedded_document)
  end

  def is_root?
    @is_root ||= self == root_embedded_document
  end

  class << self
    def from_template(template)
      template.datum_class.constantize.new.tap do |field|
        field.attributes = template.shared_attributes
      end
    end
  end
end
