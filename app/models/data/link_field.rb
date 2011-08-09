class LinkField < Datum
  key :title, String
  key :url, String
  key :resource_id, ObjectId
  key :resource_type, String
  belongs_to :resource, :polymorphic => true

  validates :title,
            :presence => true

  validates_presence_of :url,
                        :unless => proc { |l| l.resource_id.present? }

  validates_presence_of :resource_id,
                        :unless => proc { |l| l.url.present? }
end