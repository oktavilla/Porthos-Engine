class Page < Section
  key :position, Integer

  before_create :move_to_list_bottom

  scope :with_page_template, lambda { |page_template_id|
    where(:page_template_id => page_template_id)
  }

  scope :is_published, lambda { |is_published|
    if Boolean.to_mongo(is_published)
      where(:published_on.lte => Time.now)
    else
      where(:published_on => nil)
    end
  }

  scope :include_restricted, lambda { |restricted|
    where(:$or => [{:restricted => restricted}, { :restricted => false}])
  }

  def can_have_a_node?
    published_on.present? && page_template.allow_node_placements? && node.blank?
  end

  def index_node
    @index_node ||= Node.where(controller: 'pages', action: 'index', page_template_id: self.page_template_id)
  end

  def in_restricted_context?
    @in_restricted_context ||= restricted? || node_restricted? || index_node_restricted?
  end

  def category
    @category ||= page_template.allow_categories? ? tags(page_template.handle).first : nil
  end

  def category_name
    @category_name ||= category ? category.name : ''
  end

  def category_method_name
    @category_method_name ||= "#{page_template.handle}_tag_names"
  end

  # Sortable methods
  def in_list?
    @in_list ||= page_template && page_template.pages_sortable?
  end

  def previous
    Page.with_page_template(self.page_template_id).where(:position.lt => self.position).first if in_list?
  end

  def next
    Page.with_page_template(self.page_template_id).where(:position.gt => self.position).first if in_list?
  end

  class << self
    def from_template(template, attributes = {})
      self.new(attributes.merge(:page_template_id => template.id, :handle => template.handle)).tap do |page|
        page.data = template.datum_templates.map do |datum_template|
          datum_template.datum_class.constantize.from_template(datum_template)
        end
      end
    end

    def create_from_template(template, attributes = {})
      self.from_template(template, attributes).tap do |page|
        page.save
      end
    end
  end

private

  def move_to_list_bottom
    if position.blank? && in_list?
      last_in_list = Page.where(:page_template_id => self.page_template_id).
                       sort(:position.desc).
                       fields(:position).limit(1).
                       first
      self.position = last_in_list ? last_in_list.position + 1 : 1
    end
  end

  def node_restricted?
    node && (node.restricted? || node.ancestors.detect { |n| n.restricted? })
  end

  def index_node_restricted?
    index_node && (index_node.restricted? || index_node.ancestors.detect { |n| n.restricted? })
  end
end
