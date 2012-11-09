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
  belongs_to :display_option

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

  def url options = {}
    default_size = options.delete :default_size
    if ! options[:size]
      if display_option.present? && image?
        options.merge! size: display_option.format
      elsif default_size
        options[:size] = default_size
      end
    end

    asset.url options
  end

  def css_class
    display_option.try(:css_class)
  end

  def display_options
    @display_options ||= begin
      if _parent_document && _parent_document.is_a?(DatumCollection) && image?
        DisplayOption.by_group('image').ordered
      else
        []
      end
    end
  end

  def image?
    asset_id.present? && asset.of_the_type("image")
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
