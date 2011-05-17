class Template
  include MongoMapper::Document
  key :label, String
  key :description, String

  many :datum_templates, :order => 'position asc'
end