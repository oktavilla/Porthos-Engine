class Content < ActiveRecord::Base
  belongs_to :context,
             :polymorphic => true,
             :touch => true
  belongs_to :resource,
             :polymorphic => true
  belongs_to :content_collection,
             :foreign_key => 'parent_id'

  scope :active, where("contents.active = ?", true)

  # resort!

  def siblings
    self.class.where({
      :parent_id => parent_id,
      :column_position => column_position,
      :context_id => context_id,
      :context_type => context_type
    })
  end

  acts_as_settingable


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
end
