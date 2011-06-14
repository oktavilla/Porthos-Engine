class Page
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  taggable
  key :page_template_id, ObjectId
  key :created_by_id, ObjectId
  key :updated_by_id, ObjectId
  key :position, Integer
  key :title, String
  key :uri, String
  key :layout_class, String
  key :active, Boolean
  key :restricted, Boolean
  key :published_on, Time
  timestamps!

  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :page_template

  many :data, :order => 'position asc' do
    def [](handle)
      detect { |d| d.handle == handle.to_s }
    end
  end

  validates_presence_of :title

  before_create :set_created_by
  before_save :set_updated_by
  before_save :sort_data

  before_validation do
    self.title.strip! if title.present?
  end

  acts_as_uri :title,
              :target => :uri,
              :only_when_blank => true,
              :scope => :page_template_id

  class << self

    def contributors
      User.find(self.fields(:updated_by_id).distinct(:updated_by_id))
    end

    def from_template(template, attributes = {})
      self.new(attributes.merge(:page_template_id => template.id)).tap do |page|
        page.data = template.datum_templates.map do |datum_template|
          datum_template.datum_class.constantize.from_template(datum_template)
        end
      end
    end

  end

  def node
    @node ||= Node.where(:resource_type => 'Page', :resource_id => self.id).first
  end

  def node=(node_attributes)
    node ? node.attributes.merge(node_attributes) : Node.new(node_attributes).first
  end

  def index_node
    @index_node ||= Node.where(controller: 'pages', action: 'index', page_template_id: self.page_template_id)
  end

  delegate :template,
           :to => :page_template

  scope :unpublished, lambda {
    where(:$or => [{:published_on => nil}, {:published_on.gt => Time.now}])
  }

  scope :published, lambda {
    where(:published_on.lte => Time.now)
  }

  scope :published_within, lambda { |from, to|
    where(:published_on.gte => from, :published_on.lte => to)
  }

  scope :include_restricted, lambda { |restricted|
    where(:$or => [{:restricted => restricted}, { :restricted => false}])
  }

  scope :created_latest, sort(:created_at.desc)

  scope :updated_latest, where(:updated_at.gt => :created_at).sort(:updated_at.desc)

  scope :with_page_template, lambda { |page_template_id|
    where(:page_template_id => page_template_id)
  }

  scope :created_by, lambda { |user_id|
    where(:created_by_id => user_id)
  }

  scope :updated_by, lambda { |user_id|
    where(:updated_by_id => user_id)
  }

  scope :order_by, lambda { |order_by|
    sort(order_by)
  }

  scope :is_published, lambda { |is_published|
    published = Boolean.to_mongo(is_published)
    if published
      where(:published_on.lte => Time.now)
    else
      where(:published_on => nil)
    end
  }

  def published_on_parts
    @published_on_parts ||= {
      :year => published_on.strftime("%Y"),
      :month => published_on.strftime("%m"),
      :day => published_on.strftime("%d")
    }
  end

  def published?
    published_on.present? && published_on <= DateTime.now
  end

  def full_uri
    # @full_uri ||= node ? node.url : (index_node ? [index_node.url, to_param].join('/') : uri)
  end

  def category
    @category ||= page_template.allow_categories? ? Page.tags_by_count(:namespace => page_template.handle).first : nil
  end

  def category_name
    @category_name ||= category ? category.name : ''
  end

  def category_method_name
    @category_method_name ||= "#{page_template.handle}_tag_names"
  end

  def can_have_a_node?
    published_on.present? && page_template.allow_node_placements? && node.blank?
  end

  def in_restricted_context?
    @in_restricted_context ||= restricted? || node_restricted? || index_node_restricted?
  end

protected

  def create_reader_for_datum(datum)
    self.class.send :attr_reader, datum.handle
    instance_variable_set("@#{datum.handle}".to_sym, datum.value)
  end

  def node_restricted?
    node && (node.restricted? || node.ancestors.detect { |n| n.restricted? })
  end

  def index_node_restricted?
    index_node && (index_node.restricted? || index_node.ancestors.detect { |n| n.restricted? })
  end

private

  def sort_data
    self.data.sort_by!(&:position)
  end

  def set_created_by
    self.created_by = User.current
  end

  def set_updated_by
    self.updated_by = User.current
  end

end