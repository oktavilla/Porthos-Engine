class ContentTemplate < Template
  key :template_name, String
  after_destroy :propagate_removal_to_items
  after_update :propagate_updates

  class_attribute :datum_template_classes
  self.datum_template_classes = [
    { type: 'FieldTemplate', attrs: { input_type: 'string' }},
    { type: 'FieldTemplate', attrs: { input_type: 'boolean' }},
    { type: 'FieldTemplate', attrs: { input_type: 'date' }},
    { type: 'AssetAssociationTemplate' },
    { type: 'PageAssociationTemplate' },
  ]

  def template
    @template ||= template_name.present? ? FieldSetFileTemplate.new(template_name) : FieldSetFileTemplate.default
  end

  def to_datum(attrs = {})
    FieldSet.new(attrs).tap do |field_set|
      field_set.attributes = self.shared_attributes
      field_set.data = self.datum_templates.map { |t| t.to_datum }
    end
  end

  def shared_attributes
    { label: self.label, content_template_id: self.id, template_name: self.template_name }
  end

  def concerned_items
    Item.where('$or' => [
      { 'data.content_template_id' => self.id },
      { 'data.data.content_template_id' => self.id }
    ])
  end

  # Finds and returns all datums matching self in field sets connected to the content template
  def find_matching_field_sets_in_item(item)
    root_field_sets = item.data.find_all do |d|
      d.respond_to?(:content_template_id) && d.content_template_id == self.id
    end

    datum_collection_field_sets = item.data.find_all do |d|
      d.respond_to?(:content_templates_ids) && d.content_templates_ids.include?(self.id)
    end.map do |datum_collection|
      datum_collection.data.find_all do |d|
        d.respond_to?(:content_template_id) && d.content_template_id == self.id
      end
    end.flatten.compact

    root_field_sets + datum_collection_field_sets
  end

private

  # TODO: Add delayed job
  def propagate_updates
    PageTemplate.collection.update({
      'datum_templates' => {
        '$elemMatch' => { 'content_template_id' => self.id }
      }
    }, {
      '$set' => {
        'datum_templates.$.template_name' => self.template_name
      }
    }, safe: true, multiple: true)

    concerned_items.each do |item|
      find_matching_field_sets_in_item(item).each do |field_set|
        field_set.label = self.label
        field_set.template_name = self.template_name
      end
      item.save
    end
  end

  # TODO: Add delayed job
  def propagate_removal_to_items
    # Pull all field sets in pages connected to this
    Item.pull({}, data: { 'content_template_id' => self.id })

    # Pull all field sets in content blocks connected to this
    Item.collection.update({
      'data' => {
        '$elemMatch' => { 'data.content_template_id' => self.id }
      }
    }, {
      '$pull' => {
        'data.$.data' => { 'content_template_id' => self.id }
      }
    })

    PageTemplate.pull({}, datum_templates: { 'content_template_id' => self.id })
  end

end