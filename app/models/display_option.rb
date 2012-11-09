class DisplayOption
  include MongoMapper::Document

  key :name, String
  key :css_class, String
  key :format, String
  key :group_handle, String
  key :position, Integer

  before_create :move_to_list_bottom
  after_save :touch_associated_items

  timestamps!

  def touch_associated_items
    # Touch items associated to us
    Item.where(display_option_ids: self.id).each &:touch
  end

  class << self
    def groups
      [ 'image' ]
    end

    def by_group group
      where group_handle: group
    end

    def ordered
      sort :position.asc
    end
  end

  private

  def move_to_list_bottom
    last_in_list = DisplayOption.sort(:position.desc).fields(:position).limit(1).first
    self.position = last_in_list ? last_in_list.position.to_i + 1 : 1
  end

end
