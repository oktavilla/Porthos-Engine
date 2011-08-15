class AssetAssociation < Datum
  plugin MongoMapper::Plugins::Dirty

  key :title, String
  key :description
  key :asset_id, ObjectId
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  belongs_to :asset

  before_save :dup_asset_attributes
  before_save :notify_asset

private

  def dup_asset_attributes
    if asset && new?
      %w{title description author}.each do |field|
        self[field] = asset[field]
      end
    end
  end

  def notify_asset
    if changes.include?(:asset_id)
      unless asset_id_was.nil?
       Asset.find(asset_id_was).remove_usage(self._root_document)
      end
      asset.add_usage(self._root_document)
    end
  end

end
