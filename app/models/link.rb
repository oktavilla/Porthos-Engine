class Link
  include MongoMapper::EmbeddedDocument

  key :title, String
  key :url, String
  key :position, Integer

  key :node_id, ObjectId
  key :node_url, String
  belongs_to :node

  validates :title,
            :presence => true

  validates_presence_of :url,
                        :unless => proc { |l| l.node_id.present? }

  validates_presence_of :node_id,
                        :unless => proc { |l| l.url.present? }

  before_validation :cache_node_url

  def url
    node_url || self[:url]
  end

private

  def cache_node_url
    if node
      self.url = nil
      self.node_url = "/#{node.url}"
    else
      self.node_url = nil
    end
  end

end