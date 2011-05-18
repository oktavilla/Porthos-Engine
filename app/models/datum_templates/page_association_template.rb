class PageAssociationTemplate < DatumTemplate
  key :page_template_id, ObjectId
  belongs_to :page_template
end