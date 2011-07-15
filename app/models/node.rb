class Node
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap
  include MongoMapper::Acts::Tree

  acts_as_tree :order => "position asc"

  key :name, String
  key :url, String
  key :controller, String
  key :action, String
  key :status, Integer
  key :restricted, Boolean, :default => lambda{ false }
  key :position, Integer

  key :resource_id, ObjectId
  key :resource_type, String
  key :handle, String

  belongs_to :resource,
             :polymorphic => true

  validates :handle,
            :uniqueness => true,
            :allow_blank => true

  validates :url,
            :presence => true,
            :uniqueness => true,
            :if => Proc.new { !Node.count.zero? }

  validates :controller, :presence => true
  validates :action, :presence => true

  after_save :generate_url_for_children
  before_save :ensure_position
  before_validation :generate_url

  def resource_type=(r_type)
     super(r_type.to_s.classify.constantize.to_s)
  end

  def access_status
    @access_status ||= case status
    when -1 then 'inactive'
    when  0 then 'hidden'
    when  1 then 'active'
    end
  end

  def active?
    access_status == 'active'
  end

  def hidden?
    access_status == 'hidden'
  end

  def inactive?
    access_status == 'inactive'
  end

  class << self

    def for_item(item)
      self.new.tap do |node|
        node.name = item.title
        node.controller = 'pages'
        if item.is_a?(Page)
          node.action = 'show'
        elsif item.is_a?(Section)
          node.action = 'index'
          node.handle = item.page_template.handle
        end
        node.resource = item
        node.parent = Node.root if node.parent_id.blank?
      end
    end

    def root
      roots.any? ? roots.first : nil
    end

  end

private

  def generate_url
    if parent
      new_url = url.blank? ? name.to_s.to_url : url
      self.url = !parent.parent_id.blank? ? [parent.url, new_url].join('/') : new_url
    end
  end

  def generate_url_for_children
    children.each(&:save) if changes.keys.include?('url') && children.any?
  end

  def ensure_position
    if self.position.blank?
      self.position = if siblings.any?
        siblings.collect { |s| s.position.to_i }.sort.last+1
      else
        0
      end
    end
  end

end
