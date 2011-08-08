class PageTemplate < Template
  key :handle, String
  key :page_label, String
  key :template_name, String
  key :pages_sortable, Boolean, :default => lambda { false }
  key :allow_categories, Boolean, :default => lambda { false }
  key :allow_node_placements, Boolean, :default => lambda { false }

  validates_presence_of :handle
  validates_uniqueness_of :handle,
                          :case_sensitive => false,
                          :allow_blank => true

  attr_accessor :handle_was_changed

  class_attribute :datum_template_classes
  self.datum_template_classes = [
    { type: 'FieldTemplate', attrs: { input_type: 'string' }},
    { type: 'FieldTemplate', attrs: { input_type: 'boolean' }},
    { type: 'FieldTemplate', attrs: { input_type: 'date' }},
    { type: 'AssetAssociationTemplate' },
    { type: 'PageAssociationTemplate' },
    { type: 'FieldSetTemplate' },
    { type: 'DatumCollectionTemplate' }
  ]

  before_validation proc { self.handle_was_changed = true if changes.key?('handle') }
  after_save proc {
      Rails.env.production? ? delay.propagate_handle : propagate_handle
      self.handle_was_changed = false
    },
    :if => proc { handle_was_changed }

  def section
    @section ||= Section.published.where(page_template_id: self.id).first
  end

  def template
    @template ||= template_name.present? ? PageFileTemplate.new(template_name) : PageFileTemplate.default
  end

  def propagate_handle
    Page.set({ 'page_template_id' => self._root_document.id }, { :handle => handle })
  end
end