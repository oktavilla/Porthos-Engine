class PageTemplate < Template
  plugin MongoMapper::Plugins::IdentityMap
  plugin Porthos::MongoMapper::Plugins::Instructable

  key :handle, String
  key :page_label, String
  key :template_name, String
  key :pages_sortable, Boolean, :default => lambda { false }
  key :allow_categories, Boolean, :default => lambda { false }
  key :allow_node_placements, Boolean, :default => lambda { false }

  one :section

  validates_presence_of :handle
  validates_uniqueness_of :handle,
                          :case_sensitive => false,
                          :allow_blank => true

  attr_accessor :should_propagate

  class_attribute :datum_template_classes
  self.datum_template_classes = [
    { type: 'FieldTemplate', attrs: { input_type: 'string' }},
    { type: 'FieldTemplate', attrs: { input_type: 'boolean' }},
    { type: 'FieldTemplate', attrs: { input_type: 'date' }},
    { type: 'LinkFieldTemplate' },
    { type: 'AssetAssociationTemplate' },
    { type: 'PageAssociationTemplate' },
    { type: 'FieldSetTemplate' },
    { type: 'DatumCollectionTemplate' }
  ]

  before_validation proc { self.should_propagate = true if changes.any? }
  after_save proc {
    Rails.env.production? ? delay.propagate_updates : propagate_updates
    self.should_propagate = false
  }, :if => proc { should_propagate }

  def template
    @template ||= template_name.present? ? PageFileTemplate.new(template_name) : PageFileTemplate.default
  end

  def propagate_updates
    Page.set({
      'page_template_id' => self._root_document.id
    }, self.shared_attributes.except(:page_template_id))
  end

  def shared_attributes
    { page_template_id: self.id, handle: self.handle, instruction_id: self.instruction_id }
  end
end