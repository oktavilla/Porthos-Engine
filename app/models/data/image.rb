class Image < Datum
  key :asset_id, ObjectId
  belongs_to :asset
end