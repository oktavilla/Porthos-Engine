module Porthos
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end
end

require 'bcrypt'
require 'resizor'
require 'has_scope'
require 's3'

require 'porthos/redirects'
require 'porthos/engine'
require 'porthos/routing'
require 'porthos/url_resolver'
require 'porthos/authentication'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/model_restrictions'
require 'porthos/acts_as_taggable'
require 'porthos/validators'
require 'porthos/acts_as_settingable'
require 'porthos/content_resource'
require 'porthos/custom_association_proxy'
require 'porthos/s3_storage'
