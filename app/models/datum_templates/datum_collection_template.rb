class DatumCollectionTemplate < DatumTemplate
  key :allow_texts, Boolean, default: -> { false }
  key :allow_links, Boolean
  key :allowed_asset_filetypes, Array, default: -> { [] }
  key :allowed_page_template_ids, Array, typecast: 'ObjectId', default: -> { [] }
  key :content_templates_ids, Array, typecast: 'ObjectId', default: -> { [] }

  many :content_templates, in: :content_templates_ids

  before_validation do
    self.allowed_asset_filetypes = allowed_asset_filetypes.compact.reject { |i| i.blank? }
    self.allowed_page_template_ids = allowed_page_template_ids.compact.reject { |i| i.blank? }
    self.content_templates_ids = content_templates_ids.compact.reject { |i| i.blank? }
  end
end
