require 'bcrypt'
require 'warden'
require 'resizor'
require 'has_scope'
require 's3'
require 'mongo_mapper_acts_as_tree'
require 'mm-multi-parameter-attributes'
require 'delayed_job'

module Porthos
  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end

  def self.app_name
    Rails.application.class.to_s.split("::").first
  end
end

require 'porthos/engine'
require 'porthos/redirects'
require 'porthos/routing'
require 'porthos/url_resolver'
require 'porthos/authentication'
require 'porthos/helpers/application_helper'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/validators'
require 'porthos/s3_storage'
require 'porthos/active_record/restrictions'
require 'porthos/active_record/settingable'
require 'porthos/mongo_mapper/taggable'
require 'porthos/mongo_mapper/instructable'
require 'porthos/datum_methods'
require 'porthos/tags_autocomplete_app'
require 'porthos/asset_tanker_settings'