class ContentBlockTemplate < DatumTemplate
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  key :allowed_page_template_ids, Array, :default => lambda { [] }
  key :allow_texts, Boolean, :default => lambda { false }
  key :content_templates_ids, Array, :typecast => 'ObjectId'

  many :content_templates, :in => :content_templates_ids
end
