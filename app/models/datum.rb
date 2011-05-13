class Datum
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  key :active, Boolean, :default => lambda { true }

  class << self
    def from_template(template)
      template.datum_class.constantize.new.tap do |field|
        field.attributes = template.shared_attributes
      end
    end
  end
end