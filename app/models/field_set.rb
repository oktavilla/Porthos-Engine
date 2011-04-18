class FieldSet
  include MongoMapper::Document

  key :title, String, :required => true, :unique => true
  key :page_label, String, :required => true
  key :description, String
  key :handle, String, :required => true, :unique => true
  key :template, String
  key :page_sortable, Boolean
  key :allow_categories, Boolean, :default => lambda {false}
  key :allow_node_placements, Boolean, :default => lambda {false}

  many :fields, :dependent => :destroy
  many :pages, :dependent => :destroy
  one :node

  timestamps!

  def dates_with_children(options = {})
   # options = { :year => Time.now.year }.merge(options.symbolize_keys)
   # case ActiveRecord::Base.connection.adapter_name
   # when 'PostgreSQL'
   #   years = connection.select_values("SELECT DISTINCT DATE_PART('year', published_on) AS year FROM pages
   #                                     WHERE field_set_id = #{ self.id } AND published_on <= NOW() ORDER BY year DESC")
   #   years.collect do |year|
   #     months = connection.select_values("SELECT DISTINCT DATE_PART('month', published_on) AS month, DATE_PART('year', published_on) AS year FROM pages
   #                                        WHERE DATE_PART('year', published_on) = #{ year } AND field_set_id = #{ self.id } AND published_on <= NOW() ORDER BY month DESC")
   #     [year, months.collect { |month| "%02d" % month }.sort ]
   #   end
   # else
   #   years = connection.select_values("SELECT DISTINCT YEAR(published_on) AS year FROM pages
   #                                     WHERE field_set_id = #{ self.id } AND published_on <= NOW() ORDER BY year DESC")
   #   years.collect do |year|
   #     months = connection.select_values("SELECT DISTINCT MONTH(published_on) AS month, YEAR(published_on) AS year FROM pages
   #                                        WHERE YEAR(published_on) = #{ year } AND field_set_id = #{ self.id } AND published_on <= NOW() ORDER BY month DESC")
   #     [year, months.collect { |month| "%02d" % month }.sort ]
   #   end
   # end
  end

  before_validation :parameterize_handle

  def template
    @template ||= template_name.present? ? PageTemplate.new(template_name) : PageTemplate.default
  end

  # Instantiates a new page renderer
  def renderer(action, controller, objects = {})
    "#{template.name.camelize}Renderer::#{action.to_s.camelize}".constantize.new(controller, objects.to_options.merge({ :field_set => self }))
  end

  def tags_for_pages
    []#@tags_for_pages ||= Tag.on('Page').joins('LEFT OUTER JOIN pages ON pages.id = taggings.taggable_id').where(['pages.id IS NOT NULL AND pages.field_set_id = ? AND namespace IS NULL', self.id])
  end


protected

  def parameterize_handle
    self.handle = handle.parameterize if handle.present?
  end

end
