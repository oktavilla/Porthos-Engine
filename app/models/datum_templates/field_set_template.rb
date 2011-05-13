class FieldSetTemplate < DatumTemplate
  include MongoMapper::Document
  key :template, String

  many :field_templates
end