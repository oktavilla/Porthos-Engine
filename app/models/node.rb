class Node
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap
  plugin MongoMapper::Plugins::Tree

  self.tree_order = :position.asc

  key :name, String
  key :slug, String
  key :url, String
  key :controller, String
  key :action, String
  key :status, Integer, :default  => 1
  key :restricted, Boolean, :default -> { false }
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

  def access_status
    case status
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

  def toggle!
    inactive? ? activate : inactivate

    if self.resource && self.resource.is_a?(Item)
      if inactive?
        self.resource.unpublish
      else
        self.resource.publish
      end
      self.resource.save!
    end

    save!
  end

  def inactivate
    self.status = -1
  end

  def activate
    self.status = 0
  end

  class << self

    def for_item(item)
      self.new.tap do |node|
        node.name = item.title
        node.controller = 'pages'
        if item.class == Section
          node.action = 'index'
          node.handle = item.page_template.handle
        else
          node.action = 'show'
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
      new_url = slug.blank? ? name.to_s.to_url : slug
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
