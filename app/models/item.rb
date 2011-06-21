class Item
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :page_template_id, ObjectId
  key :created_by_id, ObjectId
  key :updated_by_id, ObjectId
  key :title, String
  key :active, Boolean
  key :published_on, Time
  key :restricted, Boolean
  key :uri, String

  acts_as_uri :title,
              :target => :uri,
              :only_when_blank => true,
              :scope => :page_template_id
  timestamps!

  taggable

  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :page_template

  many :data, :order => 'position asc' do
    def [](handle)
      detect { |d| d.handle == handle.to_s }
    end
  end

  delegate :template,
           :to => :page_template

  validates_presence_of :title

  before_validation { self.title.strip! if title }
  before_create :set_created_by
  before_save :set_updated_by
  before_save :sort_data

  scope :unpublished, lambda {
    where(:$or => [{:published_on => nil}, {:published_on.gt => Time.now}])
  }

  scope :published, lambda {
    where(:published_on.lte => Time.now)
  }

  scope :published_within, lambda { |from, to|
    where(:published_on.gte => from, :published_on.lte => to)
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

  class << self
    def contributors
      User.find(self.fields(:updated_by_id).distinct(:updated_by_id))
    end
  end

  def published?
    published_on.present? && published_on <= DateTime.now
  end

  def can_have_a_node?
    published_on.present? && page_template.allow_node_placements? && node.blank?
  end

  def node
    @node ||= Node.where(:resource_type => 'Page', :resource_id => self.id).first
  end

  def node=(node_attributes)
    node ? node.attributes.merge(node_attributes) : Node.new(node_attributes).first
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