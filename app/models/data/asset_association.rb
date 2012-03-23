class AssetAssociation < Datum
  plugin MongoMapper::Plugins::Dirty

  attr_accessor :should_revert_to_asset_attributes,
                :should_clear_association

  key :title, String
  key :description, String
  key :author, String
  key :asset_id, ObjectId
  key :allowed_asset_filetypes, Array, :default => lambda { [] }
  belongs_to :asset

  before_save :notify_asset
  before_validation :clear_association
  before_validation :revert_to_asset_attributes

  def title
    @title ||= self_or_asset_attribute 'title'
  end

  def description
    @description ||= self_or_asset_attribute 'description'
  end

  def author
    @author ||= self_or_asset_attribute 'author'
  end

  private
  
  def self_or_asset_attribute(attribute)
    if self[attribute].present?
      self[attribute]
    elsif asset_id.present?
      asset[attribute] if self.asset
    end
  end

  def clear_association
    if !!Boolean.to_mongo(should_clear_association) && asset_id.present?
      self.should_revert_to_asset_attributes = true
      revert_to_asset_attributes
      self['asset_id'] = nil
    end
  end

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
