require 'bcrypt'
require 'warden'
require 'resizor'
require 'routing_filter'
require 'has_scope'
require 's3'
require 'mongo_mapper_tree'
require 'mm-multi-parameter-attributes'
require 'delayed_job'
require 'kaminari'

require 'porthos/config'
module Porthos
  extend self

  def root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end

  def app_name
    Rails.application.class.to_s.split("::").first
  end

  def configure
    yield Porthos::Config
  end

  def config
    Porthos::Config
  end
end

require 'porthos/s3_storage'

# ActiveRecord
require 'porthos/active_record/restrictions'
require 'porthos/active_record/settingable'

# MongoMapper
require 'porthos/mongo_mapper/extensions'
require 'porthos/mongo_mapper/callbacks'
require 'porthos/mongo_mapper/observer'

# MongoMapper Plugins
require 'porthos/mongo_mapper/plugins/acts_as_uri'
require 'porthos/mongo_mapper/plugins/instructable'
require 'porthos/mongo_mapper/plugins/taggable'

# SearchEngine
require 'porthos/tanking'

# Routing
require 'porthos/routing/cache'
require 'porthos/routing/rule'
require 'porthos/routing/rules'
require 'porthos/routing/recognize'
require 'porthos/routing/resolver'
require 'porthos/routing/filters'

# MiddleWare
require 'porthos/middleware/redirect_app'
require 'porthos/middleware/tags_autocomplete_app'
require 'porthos/middleware/routing_cache'

# ActiveModel
require 'porthos/validators'

# Application
require 'porthos/authentication'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/helpers/application_helper'

require 'porthos/datum_methods'

require 'porthos/engine'
