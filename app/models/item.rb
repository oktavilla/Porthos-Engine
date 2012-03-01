class Item
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap
  include Tanker

  tankit Porthos.config.tanking.index_name do
    indexes :title
    indexes :uri
    indexes :tag_names
    indexes :data
    indexes :note
  end

  key :created_by_id, ObjectId
  key :updated_by_id, ObjectId

  key :title, String
  key :uri, String
  key :handle, String
  key :note

  key :active, Boolean
  key :restricted, Boolean

  key :published_on, Time
  
  key :association_ids, Array, typecast: 'ObjectId'
  
  timestamps!

  taggable

  belongs_to :created_by,
             :class_name => 'User'

  belongs_to :updated_by,
             :class_name => 'User'

  many :data, :order => 'position asc' do
    def [](handle)
      detect { |d| d.handle == handle }
    end
  end

  validates_presence_of :title

  before_validation { self.title.strip! if title }
  before_create :set_created_by
  before_save :set_updated_by
  before_save :sort_data
  before_save :store_association_ids
  
  after_save :touch_associations
  after_save proc { |page| page.delay.update_tank_indexes }
  after_destroy proc { |page| page.delete_tank_indexes }

  scope :by_class, lambda { |klass_name| where(type: klass_name) }

  scope :order_by, lambda { |order_by| sort(order_by) }

  scope :published, lambda { where(:published_on.lte => Time.now) }

  scope :unpublished, lambda {
    where(:$or => [{:published_on => nil}, {:published_on.gt => Time.now}])
  }

  scope :published_within, lambda { |from, to|
    where(:published_on.gte => from, :published_on.lte => to)
  }

  scope :created_latest, sort(:created_at.desc)

  scope :updated_latest, where(:updated_at.gt => :created_at).sort(:updated_at.desc)

  scope :created_by, lambda { |user_id| where(:created_by_id => user_id) }

  scope :updated_by, lambda { |user_id| where(:updated_by_id => user_id) }

  class << self
    def contributors
      User.find(self.fields(:updated_by_id).distinct(:updated_by_id))
    end
  end

  def published?
    published_on.present? && published_on <= DateTime.now
  end

  def can_have_a_node?
    false
  end

  def node
    @node ||= Node.where(:resource_type => self.class.model_name, :resource_id => self.id).first
  end

  def node=(node_attributes)
    node ? node.attributes.merge(node_attributes) : Node.new(node_attributes).first
  end

  def has_url?
    published? and node.present?
  end

  def find_association_ids(source = nil)
    collection = source || self.data
    result = []

    collection.find_all { |d| d.active? }.each do |d|
      if d.respond_to?(:page_id)
        result << d.page_id
      elsif d.respond_to?(:data) && d.data.any?
        result += find_association_ids(d.data)
      end
    end

    result.compact.uniq
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
  
  def store_association_ids
    self.association_ids = find_association_ids
  end

  def touch_associations
    Item.collection.update({
      :association_ids => self.id
    }, :'$set' => { :updated_at => self.updated_at.utc })
  end
  
end
