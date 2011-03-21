class Content < ActiveRecord::Base
  belongs_to :context,
             :polymorphic => true
  belongs_to :resource,
             :polymorphic => true
  belongs_to :content_collection,
             :foreign_key => 'parent_id'
  has_many :restrictions

  scope :active, where("contents.active = ?", true)

  acts_as_list :scope => 'context_id = \'#{context_id}\' AND context_type = \'#{context_type}\' AND column_position = \'#{column_position}\' AND parent_id #{(parent_id.blank? ? "IS NULL" : (" = " + parent_id.to_s))}'
  
  acts_as_settingable
  
  attr_accessor :multiple_restrictions
  
  after_save :notify_context,
             :set_restrictions
  
  before_destroy do |content|
    content.resource.destroy if content.resource and not content.module?
  end

  # Should destroy content_collection if last child
  after_destroy do |content|
    unless content.parent_id.blank?
      content.content_collection.destroy if Content.count(:conditions => ["parent_id = ?", content.parent_id]) == 0
    end
  end

  def resource_class
    @resource_class ||= resource_type.constantize
  end

  def text?
    resource_type == 'ContentTextfield'
  end
  
  def module?
    resource_type == 'ContentModule'
  end

  def pre_renderable?
    !module?
  end

  def public_template
    @public_template ||= if collection?
      "/pages/contents/#{resource_type.underscore.pluralize}/collection"
    elsif module?
      "/pages/contents/modules/#{resource.template}/content.html.erb"
    else
      "/pages/contents/#{resource_type.underscore.pluralize}/#{resource_type.underscore}"
    end
  end

  def resource_template
    "admin/contents/#{resource_type.underscore.pluralize}/#{resource_type.underscore}.html.erb"
  end

  def collection_template
    "admin/contents/#{resource_type.underscore.pluralize}/collection.html.erb"
  end

  def collection?
    self.is_a?(ContentCollection)
  end  
  def viewable_by(user)
    !self.restrictions.detect { |r| r.denies?(user) }
  end
  
  def restricted?
    !restrictions_count.nil? && restrictions_count > 0
  end
  
protected

  def notify_context
    if context && context.respond_to?(:updated_at)
      context.updated_at = Time.now and context.save
    end
  end

  def set_restrictions
    self.restrictions.destroy_all
    unless multiple_restrictions.nil?
      multiple_restrictions.each do |key|
        self.restrictions << self.restrictions.create(:mapping_key => key)
      end
    end
  end

end
