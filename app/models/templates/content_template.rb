class ContentTemplate < Template
  key :template_name, String
  after_destroy :propagate_removal_to_pages
  after_update :propagate_updates

  def template
    @template ||= template_name.present? ? FieldSetFileTemplate.new(template_name) : FieldSetFileTemplate.default
  end

<<<<<<< HEAD
  def to_datum(attrs = {})
    FieldSet.new(attrs).tap do |field_set|
=======
  def to_datum
    FieldSet.new.tap do |field_set|
>>>>>>> d8afaf751d88145347e19af44eaa84d9996d2212
      field_set.attributes = self.shared_attributes
      field_set.data = self.datum_templates.map { |t| t.to_datum }
    end
  end

  def shared_attributes
    { label: self.label, content_template_id: self.id, template_name: self.template_name }
  end

  def concerned_pages
    Page.where('$or' => [
      { 'data.content_template_id' => self.id },
      { 'data.data.content_template_id' => self.id }
    ])
  end

  # Finds and returns all datums matching self in field sets connected to the content template
  def find_matching_field_sets_in_page(page)
    root_field_sets = page.data.find_all do |d|
      d.respond_to?(:content_template_id) && d.content_template_id == self.id
    end

    datum_collection_field_sets = page.data.find_all do |d|
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

    concerned_pages.each do |page|
      find_matching_field_sets_in_page(page).each do |field_set|
        field_set.label = self.label
        field_set.template_name = self.template_name
      end
      page.save
    end
  end

  # TODO: Add delayed job
  def propagate_removal_to_pages
    # Pull all field sets in pages connected to this
    Page.pull({}, data: { 'content_template_id' => self.id })

    # Pull all field sets in content blocks connected to this
    Page.collection.update({
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