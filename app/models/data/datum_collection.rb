class DatumCollection < Datum
  key :allow_texts, Boolean, :default => lambda { false }
  key :allow_links, Boolean
  key :allowed_asset_filetypes,   Array, :default => lambda { [] }
  key :allowed_page_template_ids, Array, :typecast => 'ObjectId'
  key :content_templates_ids,     Array, :typecast => 'ObjectId'

  many :content_templates, :in => :content_templates_ids
  many :data do
    def active
      find_all { |d| d.active? }
    end
  end

  before_save :sort_data
  before_validation do
    self.allowed_asset_filetypes   = allowed_asset_filetypes.reject(&:blank?)
    self.allowed_page_template_ids = allowed_page_template_ids.reject(&:blank?)
    self.content_templates_ids     = content_templates_ids.reject(&:blank?)
  end

  def allowed_page_templates
    @allowed_page_templates ||= PageTemplate.find(allowed_page_template_ids)
  end

  def pages
    @pages ||= Item.published.where(:id.in => self.page_ids)
  end

  def page_ids
    @page_ids ||= data.active.find_all { |d| d.respond_to?(:page_id) }.map { |d| d.try(:page_id) }.compact
  end

protected

  def sort_data
    self.data.sort_by!(&:position)
  end

end
