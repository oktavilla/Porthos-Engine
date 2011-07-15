class FieldSetTemplate < DatumTemplate
  key :template_name, String
  key :content_template_id, ObjectId
  belongs_to :content_template
end