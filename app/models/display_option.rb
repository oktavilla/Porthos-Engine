class DisplayOption
  include MongoMapper::Document

  key :name, String
  key :css_class, String
  key :format, String
  key :group_handle, String

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
  end
end
