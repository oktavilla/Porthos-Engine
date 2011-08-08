class Section < Item
  key :page_template_id, ObjectId

  belongs_to :page_template

  acts_as_uri :title,
              :target => :uri,
              :only_when_blank => true,
              :scope => :page_template_id

  delegate :template,
           :to => :page_template

  class << self
    def from_template(template, attributes = {})
      self.new(attributes.merge(:page_template_id => template.id))
    end
  end

  def can_have_a_node?
    false
  end
end
