class ContentTemplate < Template
  after_destroy :propagate_removal_to_pages

  def to_datum
    FieldSet.new.tap do |field_set|
      field_set.attributes = self.shared_attributes
      field_set.data = self.datum_templates.map { |t| t.to_datum }
    end
  end

  def shared_attributes
    { :label => self.label, :content_template_id => self.id }
  end

private

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