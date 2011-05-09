class Node
  include MongoMapper::Document
  include MongoMapper::Acts::Tree

  acts_as_tree :order => "position asc"


  key :name, String
  key :url, String
  key :controller, String
  key :action, String
  key :status, Integer
  key :restricted, Boolean, :default => lambda{false}

  key :resource_id, ObjectId
  key :resource_type, String

  key :field_set_id, ObjectId

  belongs_to :resource,
             :polymorphic => true
  belongs_to :field_set

  validates :url,
            :presence => true,
            :uniqueness => true,
            :if => Proc.new {!Node.count.zero?}
  validates :controller, :presence => true
  validates :action, :presence => true

  after_save  :generate_url_for_children
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

    def for_page(page)
      self.new.tap do |node|
        node.name       = page.title
        node.controller = page.class.to_s.tableize
        node.action     = 'show'
        node.resource   = page
        node.field_set = page.field_set
        node.parent = Node.root if node.parent_id.blank?
      end
    end

    def root
      roots.first
    end

  end

private

  # before save
  def generate_url
    if parent
      self.url = !parent.parent_id.blank? ? [parent.url, name.parameterize.to_s].join('/') : name.parameterize.to_s
    end
  end

  # after save
  def generate_url_for_children
    children.each(&:save) if changes.keys.include?('url') && children.any?
  end

end