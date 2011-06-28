class Section < Item
  class << self
    def from_template(template, attributes = {})
      self.new(attributes.merge(:page_template_id => template.id))
    end
  end

  def can_have_a_node?
    true
  end
end
