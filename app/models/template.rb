class Template
  include MongoMapper::Document
  key :label, String
  key :description, String

  many :datum_templates, :order => 'position asc'

  before_save :sort_datum_templates

protected

  def sort_datum_templates
    self.datum_templates.sort_by!(&:position)
  end

end