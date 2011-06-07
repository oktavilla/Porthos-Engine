class Section < Page
  class << self
    def from_template(template, attributes = {})
      self.new(attributes.merge(:page_template_id => template.id))
    end
  end
end