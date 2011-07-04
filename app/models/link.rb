class Link
  include MongoMapper::EmbeddedDocument

  key :title, String
  key :url, String
  key :position, Integer

  key :node_id, ObjectId
  belongs_to :node

  validates :title,
            :presence => true

  validates_presence_of :url,
                        :unless => proc { |l| l.node_id.present? }

  validates_presence_of :node_id,
                        :unless => proc { |l| l.url.present? }

end