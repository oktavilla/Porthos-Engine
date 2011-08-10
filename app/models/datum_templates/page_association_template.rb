class PageAssociationTemplate < DatumTemplate
  key :page_template_ids, Array, typecast: 'ObjectId'
  many :page_templates
end