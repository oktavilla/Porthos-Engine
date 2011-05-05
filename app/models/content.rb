class Content
  include MongoMapper::EmbeddedDocument
  key :active, Boolean, :default => lambda { true }
  key :position, Integer

  before_save :move_to_list_bottom

protected

  def move_to_list_bottom
    unless position.present?
      siblings = _parent_document.contents.find_all { |c| c.id != self.id }
      self.position = siblings.any? ? siblings.sort_by(&:position).last.position + 1 : 1
    end
  end

end
