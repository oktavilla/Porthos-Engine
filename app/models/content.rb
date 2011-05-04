class Content
  include MongoMapper::EmbeddedDocument
  key :active, Boolean, :default => lambda { true }
  key :position, Integer, :default => 1
end
