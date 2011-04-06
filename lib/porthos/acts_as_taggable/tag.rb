class Tag < ActiveRecord::Base
  class_inheritable_accessor :delimiter
  self.delimiter = ' '

  has_many :taggings, :dependent => :destroy
  has_many :taggables, :through => :taggings

  scope :namespaced_to, lambda { |namespace|
    joins('LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id').
    where("taggings.tag_id IS NOT NULL").
    where("taggings.namespace = ?", namespace)
  }

  scope :popular,
        select("tags.*, COUNT(taggings.tag_id) as num_taggings").
        joins("LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id").
        order("num_taggings DESC").
        group("tags.id")

  scope :on, lambda { |taggable_type|
    select('DISTINCT(tags.id), tags.*').
    joins("LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id").
    where("taggings.tag_id IS NOT NULL").
    where("taggings.taggable_type = ?", taggable_type.to_s.classify)
  }

  validates :name,
            :presence => true,
            :uniqueness => true

  before_validation :format_name

  def tagged_models
    @tagged_models ||= self.connection.select_values("SELECT DISTINCT taggings.taggable_type FROM taggings WHERE taggings.tag_id = #{id}").collect { |model| model.constantize }
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

protected

  def format_name
    self.name = name.mb_chars.strip.downcase if name.present?
  end

end