class FieldSetTemplate < DatumTemplate
  key :template, String
  key :content_template_id, ObjectId
  belongs_to :content_template
end