class Section < Item
  key :page_template_id, ObjectId
  key :association_ids, Array, typecast: 'ObjectId'

  tankit Porthos.config.tanking.index_name do
    indexes :title
    indexes :uri
    indexes :tag_names
    indexes :data
  end

  belongs_to :page_template, touch: true

  acts_as_uri :title,
              :target => :uri,
              :only_when_blank => true,
              :scope => :page_template_id

  delegate :template,
           :to => :page_template

  before_save :store_association_ids
  after_save :touch_associations

  class << self
    def from_template(template, attributes = {})
      self.new attributes.merge(page_template_id: template.id)
    end
  end

  def can_have_a_node?
    false
  end

  private

  def store_association_ids
    self.association_ids = find_association_ids
  end

  def touch_associations
    # Touch items associated to us
    Item.where(association_ids: self.id).each &:touch
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
end
