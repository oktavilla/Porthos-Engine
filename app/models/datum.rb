class Datum
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  key :updated_at, Time
  key :datum_template_id, ObjectId
  key :active, Boolean, :default => lambda { true }

  before_save :set_timestamps

  def root_embedded_document
    @root_embedded_document ||= _parent_document == _root_document ? self : _parent_document.try(:root_embedded_document)
  end

  def is_root?
    @is_root ||= self == root_embedded_document
  end

  def update_attributes(*args)
    update_timestamps
    super(*args)
  end

  class << self
    def from_template(template)
      template.datum_class.constantize.new.tap do |field|
        field.attributes = template.shared_attributes
      end
    end
  end

private

  def set_timestamps
    update_timestamps if self.updated_at.nil?
  end

  def update_timestamps
    self.updated_at = Time.now.utc
  end

end