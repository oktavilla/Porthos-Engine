class AssetAssociation < Datum
  plugin MongoMapper::Plugins::Dirty

  key :title, String
  key :description, String
  key :author, String
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
    if changes.include?(:asset_id) && asset_id.present?
      unless asset_id_was.nil?
        if old_asset = Asset.find(asset_id_was)
          old_asset.remove_usage(self)
        end
      end
      asset.add_usage(self)
    end
  end

end
