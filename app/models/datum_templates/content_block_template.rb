class ContentBlockTemplate < DatumTemplate
  key :allow_images, Boolean, :default => lambda { false }
  key :allow_pages, Boolean, :default => lambda { false }
  key :allow_texts, Boolean, :default => lambda { false }
  key :content_templates_ids, Array, :typecast => 'ObjectId'

  many :content_templates, :in => :content_templates_ids
end