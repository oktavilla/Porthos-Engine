class FieldSet < ActiveRecord::Base
  validates_presence_of :title,
                        :page_label,
                        :handle

  validates_uniqueness_of :title,
                          :handle

  has_many :fields,
           :order => 'fields.position',
           :dependent => :destroy

  has_many :pages,
           :dependent => :destroy,
           :include => [:custom_attributes, :custom_associations]

  has_one :node,
          :conditions => { :controller => 'pages', 'action' => 'index' }

  acts_as_list

  def dates_with_children(options = {})
    options = { :year => Time.now.year }.merge(options.symbolize_keys)
    years = connection.select_values("select distinct year(published_on) as year from pages where field_set_id = #{ self.id } and published_on <= now() order by year desc")
    years.collect do |year|
      months = connection.select_values("select distinct month(published_on) as month, year(published_on) as year from pages where year(published_on) = #{ year } and field_set_id = #{ self.id } and published_on <= now() order by month desc")
      [year, months.collect { |month| "%02d" % month }.sort ]
    end
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
    @tags_for_pages ||= Tag.on('Page').all(:joins => 'LEFT OUTER JOIN pages ON taggings.taggable_id = pages.id', :conditions => ['pages.field_set_id = ? AND namespace IS NULL', self.id])
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize
  end

end