class ContentImage < ActiveRecord::Base
  include Porthos::ContentResource

  belongs_to :asset, :class_name => 'ImageAsset', :foreign_key => 'image_asset_id'

  after_create :merge_with_asset

  def style_properties
    self.class.style(style)
  end

  def styles
    self.class.styles
  end

  class << self

    def style(style)
      styles.detect { |s| s[:class] == style }
    end

    def styles
      [
        {
          :class => 'full',
          :name  => 'Fullbredd',
          :size  => '640'
        }
      ]
    end

  end

protected
  def merge_with_asset
    asset.description = self.caption if asset.description.blank?
    asset.author = self.copyright if asset.author.blank?
    if asset.changed?
      asset.save
    end
  end
end
