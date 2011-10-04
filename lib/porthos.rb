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

module Porthos
  autoload :Config, 'porthos/config'

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

  module Middleware
    autoload :RedirectApp,         'porthos/middleware/redirect_app'
    autoload :TagsAutocompleteApp, 'porthos/middleware/tags_autocomplete_app'
    autoload :RoutingCache,        'porthos/middleware/routing_cache'
  end

  module Routing
    autoload :Cache,     'porthos/routing/cache'
    autoload :Rule,      'porthos/routing/rule'
    autoload :Rules,     'porthos/routing/rules'
    autoload :Recognize, 'porthos/routing/recognize'
    autoload :Filters,   'porthos/routing/filters'
  end

  autoload :S3Storage, 'porthos/s3_storage'

  autoload :Authentication, 'porthos/authentication'
  autoload :Admin,  'porthos/admin'
  autoload :Public, 'porthos/public'
  autoload :ApplicationHelper, 'porthos/helpers/application_helper'

  module ActiveRecord
    autoload :Restrictions, 'porthos/active_record/restrictions'
    autoload :Settingable,  'porthos/active_record/settingable'
  end

  module MongoMapper
    autoload :Extensions, 'porthos/mongo_mapper/extensions'
    autoload :Callbacks,  'porthos/mongo_mapper/callbacks'
    autoload :Observer,   'porthos/mongo_mapper/observer'

    module Plugins
      autoload :ActsAsUri,    'porthos/mongo_mapper/plugins/acts_as_uri'
      autoload :Instructable, 'porthos/mongo_mapper/plugins/instructable'
      autoload :Taggable,     'porthos/mongo_mapper/plugins/taggable'
    end
  end

  autoload :DatumMethods, 'porthos/datum_methods'
  autoload :Tanking,      'porthos/tanking'

end
require 'porthos/validators'
require 'porthos/engine'
