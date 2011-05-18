class Image < Datum
  key :title, String
  key :description
  key :asset_id, ObjectId
  belongs_to :asset

  before_save :dup_asset_attributes

private

  def dup_asset_attributes
    if asset
      self.title = asset.title
      self.description = asset.description
    end
  end

end