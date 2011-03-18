class ContentVideo < ActiveRecord::Base
  include Porthos::ContentResource

  belongs_to :asset, :class_name => 'VideoAsset', :foreign_key => 'video_asset_id'
end