class Template
  include MongoMapper::Document
  key :title, String
  key :handle, String
  key :description, String

  many :datum_templates, :order => 'position asc'
end