class Section < Item
  key :page_template_id, ObjectId
  key :association_ids, Array, typecast: 'ObjectId'
  key :display_option_ids, Array, typecast: 'ObjectId'

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

  before_save :store_association_ids,
              :store_display_option_ids

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

  def store_display_option_ids
    self.display_option_ids = find_display_option_ids
  end

  def touch_associations
    # Touch items associated to us
    Item.where(association_ids: self.id).each &:touch
  end

  def find_association_ids
    recursive_find_in_datum :page_id
  end

  def find_display_option_ids
    recursive_find_in_datum :display_option_id
  end

  def recursive_find_in_datum field, source = nil
    collection = source || self.data
    result = []

    collection.find_all { |d| d.active? }.each do |d|
      if d.respond_to? field
        result << d.public_send(field)
      elsif d.respond_to?(:data) && d.data.any?
        result += recursive_find_in_datum(field, d.data)
      end
    end

    result.compact.uniq
  end
end
