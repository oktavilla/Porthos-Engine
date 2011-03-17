require 'porthos/acts_as_taggable/tag'
require 'porthos/acts_as_taggable/tagging'
require 'porthos/acts_as_taggable/acts_as_taggable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)