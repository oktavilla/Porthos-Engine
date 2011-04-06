class Page < ActiveRecord::Base

  resort!

  def siblings
    self.field_set.pages
  end

  acts_as_taggable

  searchable :auto_index => false do
    integer :field_set_id
    text :title, :boost => 2.0
    text :tag_names
    time :published_on
    boolean :is_restricted, :using => :in_restricted_context?
    text :body do
       contents_as_text
    end
    text :custom_attributes_values do
      custom_attributes.map { |ca| ca.value }.join(' ')
    end
    dynamic_string :custom_attributes do
      {}.tap do |hash|
        custom_associations.each do |custom_association|
          hash[custom_association.handle.to_sym] = "#{custom_association.target_type}-#{custom_association.target_id}"
        end
        custom_attributes.all.each do |custom_attribute|
          hash[custom_attribute.handle.to_sym] = !custom_attribute.value.acts_like?(:string) ? custom_attribute.value : ActionController::Base.helpers.strip_tags(custom_attribute.value)
        end
      end
    end
  end

  validates_presence_of :title,
                        :field_set_id
  has_one :node,
          :as => :resource

  has_one :index_node,
          :through => :field_set,
          :source  => :node

  accepts_nested_attributes_for :node

  has_many :contents,
           :as    => :context,
           :conditions => ["contents.parent_id IS NULL"],
           :dependent  => :destroy

  belongs_to :field_set

  has_many :fields,
           :through => :field_set

  delegate :template,
           :to => :field_set

  has_many :custom_attributes,
           :as => :context,
           :dependent => :destroy

  has_many :custom_associations,
           :as => :context,
           :dependent => :destroy

  has_many :custom_association_contexts,
           :class_name => 'CustomAssociation',
           :as => :target,
           :dependent => :destroy

  belongs_to :created_by,
             :class_name => 'User'

  belongs_to :updated_by,
             :class_name => 'User'

  has_many :comments,
           :as => :commentable,
           :order => 'comments.created_at'

  scope :unpublished, lambda {
    where("published_on IS NULL OR published_on > ?", Time.now)
  }

  scope :published, lambda {
    where("published_on <= ?", Time.now)
  }

  scope :published_within, lambda { |from, to|
    where("published_on BETWEEN ? AND ?", from.to_s(:db), to.to_s(:db))
  }

  scope :include_restricted, lambda { |restricted|
    where('restricted = ? or restricted = ?', restricted, false)
  }

  scope :created_latest, order('created_at DESC')

  scope :updated_latest, where('updated_at > created_at').order('updated_at DESC')

  scope :with_field_set, lambda { |field_set_id|
    where("field_set_id = ?", field_set_id)
  }

  scope :created_by, lambda { |user_id|
    where("created_by_id = ?", user_id)
  }

  scope :updated_by, lambda { |user_id|
    where("updated_by_id = ?", user_id)
  }

  scope :order_by, lambda { |order_by_string|
    order(order_by_string)
  }

  scope :is_published, lambda { |is_published|
    if is_published
      where('published_on > ?', Time.now)
    else
      where('published_on IS NULL or published_on < ?', Time.now)
    end
  }

  scope :with_custom_attributes_field, lambda { |ca_field|
    joins("left join custom_attributes as #{ca_field} on #{ca_field}.context_type = 'Page' and #{ca_field}.context_id = pages.id and #{ca_field}.handle = '#{ca_field}'")
  }

  before_create :set_created_by
  before_save   :set_layout_attributes,
                :generate_slug
  before_update :set_updated_by

  after_initialize :create_namespaced_tagging_methods

  after_save :commit_to_sunspot

  def contents_as_text
    contents.active.collect do |content|
      def render_content(content_resource)
        if content_resource.is_a?(ContentImage) or content_resource.is_a?(ContentVideo)
          "#{content_resource.asset.title} #{content_resource.asset.description}"
        elsif content_resource.is_a?(ContentTextfield)
          content_resource.body
        elsif content_resource.is_a?(ContentTeaser)
          "#{content_resource.title} #{content_resource.body}"
        end
      end
      if !content.restricted? && !content.module?
        if content.collection?
          content.contents.collect {|c| render_content(c)}
        else
          render_content(content.resource)
        end
      end
    end.join(' ').gsub(/<\/?[^>]*>/, "")
  end

  def to_param
    "#{id}-#{slug}"
  end

  def published_on_parts
    @published_on_parts ||= {
      :year => published_on.strftime("%Y"),
      :month => published_on.strftime("%m"),
      :day => published_on.strftime("%d")
    }
  end

  def published?
    published_on.present? && published_on <= Time.now
  end

  def full_slug
    @full_slug ||= node ? node.url : (index_node ? [index_node.url, to_param].join('/') : slug)
  end

  def custom_value_for(field)
    unless field.data_type == CustomAssociation
      if custom_attribute = custom_attribute_for_field(field.id)
        custom_attribute.value
      end
    else
      custom_associations.with_field(field.id).all
    end
  end

  def custom_attribute_for_field(field_id)
    custom_attributes.detect { |cd| cd.field_id == field_id.to_i }
  end

  def custom_association_for_field(field_id)
    custom_associations.detect { |ca| ca.field_id == field_id.to_i }
  end

  def custom_fields=(custom_fields)
    custom_fields.each do |key, value|
      field = Field.find(key)
      unless field.data_type == CustomAssociation
        if custom_attribute = custom_attribute_for_field(field.id)
          custom_attribute.update_attributes(:value => value)
        else
          self.custom_attributes << field.data_type.new({
            :value    => value,
            :field_id => field.id,
            :handle   => field.handle,
            :context => self
          })
        end
      else
        CustomAssociation.destroy_all(:context_id => self.id, :context_type => 'Page', :field_id => field.id)
        value.to_a.reject(&:blank?).each do |association_value|
          if association_value.is_a?(StringIO) || association_value.is_a?(Tempfile)
            uploaded_asset = Asset.from_upload(:file => association_value)
            association_value = uploaded_asset.id if uploaded_asset.save
          end
          self.custom_associations << self.custom_associations.build({
            :context      => self,
            :field        => field,
            :handle       => field.handle,
            :relationship => field.relationship,
            :target_id    => association_value,
            :target_type  => field.target_class.to_s
          })
        end
      end
    end
  end

  def field_exists?(handle)
    fields.detect { |field| field.handle == handle }
  end

  def respond_to?(method, include_private = false)
    !new_record? ? (super(method, include_private) || field_exists?(method.to_s.gsub(/\?/, ''))) : super(method, include_private)
  end

  def category
    @category ||= field_set.allow_categories? ? all_tags.with_namespace(field_set.handle).first : nil
  end

  def category_name
    @category_name ||= category ? category.name : ''
  end

  def category_method_name
    @category_method_name ||= "#{field_set.handle}_tag_names"
  end

  def can_have_a_node?
    published_on.present? && field_set.allow_node_placements? && node.blank?
  end

  def in_restricted_context?
    @in_restricted_context ||= restricted? || node_restricted? || index_node_restricted?
  end

protected

  def node_restricted?
    node && (node.restricted? || node.ancestors.detect { |n| n.restricted? })
  end

  def index_node_restricted?
    index_node && (index_node.restricted? || index_node.ancestors.detect { |n| n.restricted? })
  end

  def create_namespaced_tagging_methods
    if field_set.present? && field_set.allow_categories?
      self.class.create_namespaced_tagging_methods_for(field_set.handle)
    end
  end

  def cache_custom_attributes
    custom_attributes.each do |custom_attribute|
      create_reader_for_custom_attribute(custom_attribute)
    end
  end

  def create_reader_for_custom_attribute(custom_attribute)
    self.class.send :attr_reader, custom_attribute.handle
    instance_variable_set("@#{custom_attribute.handle}".to_sym, custom_attribute.value)
  end

  def method_missing_with_find_custom_attributes(method, *args)
    # Check that we dont match any other method_missing hacks before we start query the database
    begin
      method_missing_without_find_custom_attributes(method, *args)
    rescue
      handle = method.to_s.gsub(/\?/, '')
      # raise if we do not have a matching field
      method_missing_without_find_custom_attributes(method, *args) unless fields.detect { |field| !field.is_a?(AssociationField) && field.handle == handle }
      if custom_attribute = custom_attributes.detect { |c| c.handle == handle }
        create_reader_for_custom_attribute custom_attribute
        return custom_attribute.value
      else
        nil # we have a field but no data for it yet
      end
    end
  end
  alias_method_chain :method_missing, :find_custom_attributes

  def method_missing_with_find_custom_associations(method, *args)
    # Check that we dont match any other method_missing hacks before we start query the database
    begin
      method_missing_without_find_custom_associations(method, *args)
    rescue
      if args.size == 0
        handle = method.to_s.gsub(/\?/, '')
        if field = fields.detect { |field| field.is_a?(AssociationField) && field.handle == handle }
          match = field.target_handle.blank? ? custom_associations_by_handle(handle) : custom_association_contexts_by_handle(field.target_handle)
          if match.any?
            unless field.target_handle.present?
              match.first.relationship == 'one_to_one' ? match.first.target : Porthos::CustomAssociationProxy.new({
                :target_class => match.first.target_type.constantize,
                :target_ids   => match.collect { |m| m.target_id }
              })
            else
              field.relationship == 'one_to_one' ? match.first.context : Porthos::CustomAssociationProxy.new({
                :target_class => match.first.context_type.constantize,
                :target_ids   => match.collect { |m| m.context_id }
              })
            end
          # Do we have a matching field but no records, return nil for
          # page.handle ? do stuff in the views
          else
            nil
          end
        else
          # no match raise method missing again
          method_missing_without_find_custom_associations(method, *args)
        end
      else
        method_missing_without_find_custom_associations(method, *args)
      end
    end
  end
  alias_method_chain :method_missing, :find_custom_associations

private

  def custom_associations_by_handle(handle)
    custom_associations.find_all { |ca| ca.handle == handle }
  end

  def custom_association_contexts_by_handle(handle)
    custom_association_contexts.find_all { |ca| ca.handle == handle }
  end

  def generate_slug
    self.slug = title.parameterize unless slug.present?
  end

  def set_layout_attributes
    contents.update_all("column_position = #{template.columns}", "column_position > #{template.columns}") unless column_count == template.columns or column_count.blank?
    self.layout_class = template.handle
    self.column_count = template.columns
  end

  def set_created_by
    self.created_by = User.current
  end

  def set_updated_by
    self.updated_by = User.current
  end

  def commit_to_sunspot
    Delayed::Job.enqueue SunspotIndexJob.new('Page', self.id)
  end

end
