module Porthos
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end
end
require 'porthos/engine'
require 'porthos/routing'
require 'porthos/url_resolver'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/access_controll'
require 'porthos/model_restrictions'
require 'porthos/acts_as_taggable'
require 'porthos/validators'
require 'porthos/acts_as_settingable'
require 'porthos/content_resource'
require 'porthos/custom_association_proxy'

require 'resort'
require 'sunspot'
require 'sunspot_rails'
require 'delayed_job'
require 'has_scope'
require 'will_paginate'
require 'acts_as_tree'
