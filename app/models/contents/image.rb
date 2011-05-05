class Image < Content
  key :caption, String
  key :copyright, String

  belongs_to :asset, :class_name => 'ImageAsset'
end