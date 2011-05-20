module Porthos
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end
end

require 'bcrypt'
require 'warden'
require 'resizor'
require 'has_scope'
require 's3'
require 'sprockets'
require 'mongo_mapper_acts_as_tree'
require 'mm-multi-parameter-attributes'

require 'porthos/redirects'
require 'porthos/engine'
require 'porthos/routing'
require 'porthos/url_resolver'
require 'porthos/authentication'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/model_restrictions'
require 'porthos/validators'
require 'porthos/acts_as_settingable'
require 'porthos/s3_storage'
require 'porthos/taggable'
require 'porthos/mongo_mapper/instructable'
require 'porthos/datum_methods'
require 'porthos/tags_autocomplete_app'
