class DatumCollection < Datum
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  key :allowed_page_template_ids, Array, :default => lambda { [] }
  key :allow_texts, Boolean, :default => lambda { false }
  key :content_templates_ids, Array, :typecast => 'ObjectId'

  many :content_templates, :in => :content_templates_ids
  many :data do
    def active
      find_all { |d| d.active? }
    end
  end

  before_save :sort_data

  def allowed_page_templates
    @allowed_page_templates ||= PageTemplate.find(allowed_page_template_ids)
  end

  def pages
    @pages ||= data.active.find_all { |d| d.is_a?(PageAssociation) && d.page }.collect { |d| d.page }
  end

  def texts
    @texts ||= data.active.find_all { |d| d.is_a?(StringField) }
  end

protected

  def sort_data
    self.data.sort_by!(&:position)
  end

end
