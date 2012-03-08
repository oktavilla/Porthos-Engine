# -*- coding: UTF-8 -*-
class Page < Section
  class_attribute :sortable_keys
  self.sortable_keys = [
    :created_at,
    :updated_at,
    :published_on,
    :position
  ]

  plugin Porthos::MongoMapper::Plugins::Instructable
  tankit Porthos.config.tanking.index_name do
    indexes :title
    indexes :uri
    indexes :tag_names
    indexes :data
  end
  key :position, Integer

  before_create :move_to_list_bottom
  after_save :touch_section

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

  def section
    @section ||= Section.where(page_template_id: self.page_template_id).first
  end

  def can_have_a_node?
    published_on.present? && page_template.allow_node_placements? && node.blank?
  end

  def has_url?
    published? and (node.present? or index_node.present?)
  end

  def index_node
    @index_node ||= Node.where(controller: 'pages', action: 'index', handle: self.page_template.handle)
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

  def sortable
    page_template ? page_template.sortable : nil
  end

  def sortable?
    sortable.present?
  end

  # About next and previous, think of it as a list
  # When using ascending   #   When using descending
  #         1              #          4
  #         2              #   next ↓ 3 ↑ previous
  #  next ↓ 3 ↑ previous   #          2
  #         4              #          1
  #

  def previous
    if sortable?
      get_next_or_previous(*previous_operators).first
    end
  end

  def next
    if sortable?
      get_next_or_previous(*next_operators).first
    end
  end

  def previous_in_category
    if sortable?
      get_next_or_previous(*previous_operators).where({
        :'_tags.name'.all => [category_name],
        :'_tags.namespace' => page_template.handle
      }).first
    end
  end

  def next_in_category
    if sortable?
      get_next_or_previous(*next_operators).where({
        :'_tags.name'.all => [category_name],
        :'_tags.namespace' => page_template.handle
      }).first
    end
  end

  class << self
    def from_template(template, attributes = {})
      self.new(attributes.merge(template.shared_attributes)).tap do |page|
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

  def previous_operators
    sortable.operator == 'desc' ? ['gt', 'asc'] : ['lt', 'desc']
  end

  def next_operators
    sortable.operator == 'desc' ? ['lt', 'desc'] : ['gt', 'asc']
  end

  def get_next_or_previous(compare_operator, sort_operator)
    Page.limit(1).published.where({
      :page_template_id => self.page_template_id,
      sortable.field.public_send(compare_operator) => self[sortable.field]
    }).sort(sortable.field.public_send(sort_operator))
  end

  def move_to_list_bottom
    if sortable && sortable.field == :position
      last_in_list = Page.where(page_template_id: self.page_template_id).
        sort(:position.desc).
        fields(:position).limit(1).
        first
      self.position = last_in_list ? last_in_list.position.to_i + 1 : 1
    end
  end

  def node_restricted?
    node && (node.restricted? || node.ancestors.detect { |n| n.restricted? })
  end

  def index_node_restricted?
    index_node && (index_node.restricted? || index_node.ancestors.detect { |n| n.restricted? })
  end

  def touch_section
    Section.set({ page_template_id: self.page_template_id }, { updated_at: self.updated_at.utc })
  end
end
