class DatumTemplate
  include MongoMapper::EmbeddedDocument
  include Porthos::DatumMethods

  validates_presence_of :label

  before_save :set_was_new
  after_save :propagate
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
    end.merge(:datum_template_id => self.id)
  end

private

  def set_was_new
    @was_new = self.new?
    true # keep them callbacks flowing
  end

  def propagate
    if @was_new
      propagate_self
      @was_new = false
    else
      propagate_updates
    end
    true # keep them callbacks flowing
  end

  def propagate_self
    if _root_document.is_a?(PageTemplate)
      Page.add_to_set({
        'page_template_id' => self._root_document.id
      }, {
        'data' => self.to_datum.to_mongo
      })
    elsif _root_document.is_a?(ContentTemplate)
      propagate_self_to_field_sets
    end
  end

  def propagate_updates
    if _root_document.is_a?(PageTemplate)
      updates = shared_attributes.inject({}) { |hash, (k, v)| hash.merge({ "data.$.#{k}" => v }) }
      Page.set({
        'page_template_id' => self._root_document.id,
        'data.datum_template_id' => self.id
      }, updates)
    elsif _root_document.is_a?(ContentTemplate)
      propagate_updates_to_field_sets
    end
  end

  def propagate_removal
    if _root_document.is_a?(PageTemplate)
      Page.pull({
        'page_template_id' => self._root_document.id
      }, {
        'data' => { 'datum_template_id' => self.id }
      })
    elsif _root_document.is_a?(ContentTemplate)
      propagate_removal_to_field_sets
    end
  end

  # TODO: Add delayed job
  def propagate_self_to_field_sets
    _root_document.concerned_items.each do |item|
      _root_document.find_matching_field_sets_in_item(item).each do |field_set|
        field_set.data << self.to_datum
      end
      item.save
    end
  end

  # TODO: Add delayed job
  def propagate_updates_to_field_sets
    _root_document.concerned_items.each do |item|
      _root_document.find_matching_field_sets_in_item(item).each do |field_set|
        field_set.data.detect { |datum| datum.datum_template_id == self.id }.tap do |datum|
          datum.assign(self.shared_attributes) if datum
        end
      end
      item.save
    end
  end

  # TODO: Add delayed job
  def propagate_removal_to_field_sets
    _root_document.concerned_items.each do |item|
      _root_document.find_matching_field_sets_in_item(item).each do |field_set|
        field_set.data.delete_if do |datum|
          datum.datum_template_id == self.id
        end
      end
      item.save
    end
  end
end