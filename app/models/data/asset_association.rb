class AssetAssociation < Datum
  plugin MongoMapper::Plugins::Dirty

  attr_accessor :should_revert_to_asset_attributes

  key :title, String
  key :description, String
  key :author, String
  key :asset_id, ObjectId
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  belongs_to :asset

  before_save :notify_asset
  before_validation :revert_to_asset_attributes

  def title
    if !self['title'].nil?
      self['title']
    elsif self.asset_id.present?
      self.asset.title if self.asset
    end
  end

  def description
    if !self['description'].nil?
      self['description']
    elsif self.asset_id.present?
      self.asset.description if self.asset
    end
  end

  def author
    if !self['author'].nil?
      self['author']
    elsif self.asset_id.present?
      self.asset.author if self.asset
    end
  end

private

  def revert_to_asset_attributes
    if !!Boolean.to_mongo(should_revert_to_asset_attributes) && asset_id.present?
      self['title'] = nil
      self['description'] = nil
      self['author'] = nil
    end
  end

  def notify_asset
    if changes.include?(:asset_id)
      unless asset_id_was.nil?
        if old_asset = Asset.find(asset_id_was)
          old_asset.remove_usage(self)
        end
      end
      Asset.find(asset_id).tap do |new_asset|
        new_asset.add_usage(self) if new_asset
      end if asset_id.present?
    end
  end

end
