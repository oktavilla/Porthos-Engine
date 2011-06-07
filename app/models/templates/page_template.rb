class PageTemplate < Template
  key :handle, String
  key :page_label, String
  key :template_name, String
  key :pages_sortable, Boolean, :default => lambda { false }
  key :allow_categories, Boolean, :default => lambda { false }
  key :allow_node_placements, Boolean, :default => lambda { false }

  has_one :section

  def template
    @template ||= template_name.present? ? PageFileTemplate.new(template_name) : PageFileTemplate.default
  end

  # Instantiates a new page renderer
  def renderer(action, controller, objects = {})
    "#{template.name.camelize}Renderer::#{action.to_s.camelize}".constantize.new(controller, objects.to_options.merge({ :field_set => self }))
  end
end
