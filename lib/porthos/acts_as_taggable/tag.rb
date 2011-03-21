class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :taggables, :through => :taggings

  scope :popular,
        select("tags.*, COUNT(taggings.tag_id) as num_taggings").
        joins("LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id").
        order("num_taggings DESC").
        group("tags.id")

  scope :on, lambda { |taggable_type|
    where("taggings.taggable_type = ?", taggable_type.to_s.classify).
    joins("LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id").
    group('tags.name')
  }

  validates_uniqueness_of :name

  before_validation :format_name

  def self.delimiter
    ' '
  end

  def tagged_models
    @tagged_models ||= self.connection.select_values("SELECT DISTINCT taggings.taggable_type FROM taggings WHERE taggings.tag_id = #{id}").collect { |model| model.constantize }
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

protected

  def format_name
    self.name = name.mb_chars.strip.downcase
  end

end
