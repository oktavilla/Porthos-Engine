class LinkList
  include MongoMapper::Document
  key :title, String
  key :handle, String
  timestamps!

  many :links

  validates :title, presence: true
  validates :handle, presence: true

  before_validation :create_title
  before_save :sort_links

  class << self
    def [](handle)
      find_or_create_by_handle(handle)
    end
  end

private

  def create_title
    self.title = handle.to_s.humanize unless title.present?
  end

  def sort_links
    links.sort_by!(&:position)
  end

end
