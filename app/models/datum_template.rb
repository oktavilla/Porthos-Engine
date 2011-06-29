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

    # TODO: Add delayed job
    def propagate_change(change_method, options = {})
      Page.send(change_method, options[:critera], options[:updates])
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
    if _root_document.is_a?(PageTemplate)
      DatumTemplate.propagate_change(:add_to_set, {
        critera: { 'page_template_id' => self._root_document.id },
        updates: { 'data'=> self.to_datum.to_mongo }
      })
    elsif _root_document.is_a?(ContentTemplate)
      propagate_self_to_field_sets
    end
  end

  def propagate_updates
    query_handle = respond_to?(:handle_changed?) ? (handle_changed? ? handle_was : handle) : handle
    if _root_document.is_a?(PageTemplate)
      DatumTemplate.propagate_change(:set, {
        critera: { 'page_template_id' => self._root_document.id, 'data.handle' => query_handle },
        updates: shared_attributes.inject({}) { |hash, (k, v)| hash.merge({ "data.$.#{k}" => v }) }
      })
    elsif _root_document.is_a?(ContentTemplate)
      propagate_updates_to_field_sets
    end
  end

  def propagate_removal
    if _root_document.is_a?(PageTemplate)
      DatumTemplate.propagate_change(:pull, {
        critera: { 'page_template_id' => self._root_document.id },
        updates: { 'data' => { 'handle' => self.handle } }
      })
    elsif _root_document.is_a?(ContentTemplate)
      propagate_removal_to_field_sets
    end
  end

  # TODO: Add delayed job
  def propagate_self_to_field_sets
    concerned_pages.each do |page|
      find_matching_field_sets_in_page(page).each do |field_set|
        field_set.data << self.to_datum
      end
      page.save
    end
  end

  # TODO: Add delayed job
  def propagate_updates_to_field_sets
    query_handle = respond_to?(:handle_changed?) ? (handle_changed? ? handle_was : handle) : handle
    concerned_pages.each do |page|
      find_matching_field_sets_in_page(page).each do |field_set|
        field_set.data.detect { |datum| datum.handle == query_handle }.tap do |datum|
          self.shared_attributes.each do |k, v|
            datum[k.to_sym] = v
          end
        end
      end
      page.save
    end
  end

  # TODO: Add delayed job
  def propagate_removal_to_field_sets
    query_handle = respond_to?(:handle_changed?) ? (handle_changed? ? handle_was : handle) : handle
    concerned_pages.each do |page|
      find_matching_field_sets_in_page(page).each do |field_set|
        field_set.data.delete_if do |datum|
          datum.handle == query_handle
        end
      end
      page.save
    end
  end

  def concerned_pages
    Page.where('$or' => [
      { 'data.content_template_id' => _root_document.id },
      { 'data.data.content_template_id' => _root_document.id }
    ])
  end

  # Finds and returns all datums matching self in field sets connected to the content template
  def find_matching_field_sets_in_page(page)
    root_field_sets = page.data.find_all do |d|
      d.respond_to?(:content_template_id) && d.content_template_id == _root_document.id
    end

    datum_collection_field_sets = page.data.find_all do |d|
      d.respond_to?(:content_templates_ids) && d.content_templates_ids.include?(_root_document.id)
    end.map do |datum_collection|
      datum_collection.data.find_all do |d|
        d.respond_to?(:content_template_id) && d.content_template_id == _root_document.id
      end
    end.flatten.compact

    root_field_sets + datum_collection_field_sets
  end
end