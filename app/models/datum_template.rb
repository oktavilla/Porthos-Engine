class DatumTemplate
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  validates_presence_of :label

  after_destroy :propagate_removal

  def destroy
    run_callbacks(:destroy) { delete }
  end

  def delete
    _root_document.pull(:datum_templates => { :_id => self.id })
  end

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

    def propagate_change(change_method, critera, updates)
      if ::Rails.env.production?
        Page.delay.send(change_method, critera, updates)
      else
        Page.send(change_method, critera, updates)
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
    attributes.clone.except(:_id, :_type).each_with_object({}) do |(k, v), hash|
      hash[k] = v.duplicable? ? v.clone : v
    end
  end

private

  def propagate_self
    DatumTemplate.propagate_change(:add_to_set,
      { 'page_template_id' => self._root_document.id },
      { 'data'=> self.to_datum.to_mongo})
  end

  def propagate_updates
    query_handle = respond_to?(:handle_changed?) ?
      (handle_changed? ? handle_was : handle) :
      handle
    DatumTemplate.propagate_change(:set,
      { 'page_template_id' => self._root_document.id,
        'data.handle' => query_handle },
      shared_attributes.inject({}) { |hash, (k, v)| hash.merge({ "data.$.#{k}" => v }) })
  end

  def propagate_removal
    DatumTemplate.propagate_change(:pull,
      { 'page_template_id' => self._root_document.id },
      { 'data' => { 'handle' => self.handle }})
  end

end
