require 'bcrypt'
require 'warden'
require 'resizor'
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

require 'porthos/validators'
require 'porthos/redirects'
require 'porthos/routing'
require 'porthos/url_resolver'
require 'porthos/authentication'
require 'porthos/helpers/application_helper'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/s3_storage'
require 'porthos/active_record/restrictions'
require 'porthos/active_record/settingable'
require 'porthos/mongo_mapper/extensions'
require 'porthos/mongo_mapper/callbacks'
require 'porthos/mongo_mapper/observer'
require 'porthos/mongo_mapper/taggable'
require 'porthos/mongo_mapper/instructable'
require 'porthos/mongo_mapper/acts_as_uri'
require 'porthos/datum_methods'
require 'porthos/tags_autocomplete_app'
require 'porthos/tanking'
require 'porthos/engine'