class LinkField < Datum
  key :title, String
  key :url, String
  key :resource_id, ObjectId
  key :resource_type, String
  belongs_to :resource, :polymorphic => true

  def has_target?
    url.present? || resource_id.present?
  end
end
