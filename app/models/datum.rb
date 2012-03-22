class Datum
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  key :datum_template_id, ObjectId
  key :active, Boolean, :default => lambda { true }

  def root_embedded_document
    @root_embedded_document ||= _parent_document == _root_document ? self : _parent_document.try(:root_embedded_document)
  end

  def is_root?
    @is_root ||= self == root_embedded_document
  end

  def updated_at
    _root_document.try(:updated_at)
  end

  def cache_key(*suffixes)
    cache_key = [ self.class.name ]
    if ! persisted?
      cache_key << 'new'
    else
      if timestamp = _root_document[:updated_at]
        cache_key << [ id, timestamp.to_s(:number) ].join('-')
      else
        cache_key << id
      end
      cache_key << [_root_document.class.name, _root_document.id].join('-')
    end
    cache_key += Array[*suffixes] unless suffixes.empty?
    cache_key.join('/')
  end


  class << self
    def from_template(template)
      template.datum_class.constantize.new.tap do |field|
        field.attributes = template.shared_attributes
      end
    end
  end

end
