class Content
  include MongoMapper::EmbeddedDocument
  key :active, Boolean, :default => lambda { true }
end
