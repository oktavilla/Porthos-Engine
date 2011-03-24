Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module Porthos
  def benchmark
    cur = Time.now
    result = yield
    print "#{cur = Time.now - cur} seconds"
    puts " (#{(cur / $last_benchmark * 100).to_i - 100}% change)" rescue puts ""
    $last_benchmark = cur
    result
  end

  def self.root
    Pathname.new(File.expand_path(File.dirname(__FILE__)+'../..'))
  end

  require 'porthos/engine' if defined?(Rails)
end

require 'porthos/url_resolver'
require 'porthos/admin'
require 'porthos/public'
require 'porthos/access_controll'
require 'porthos/model_restrictions'
require 'porthos/routing'
require 'porthos/acts_as_taggable'
require 'porthos/validators'
require 'porthos/acts_as_settingable'
require 'porthos/content_resource'
require 'porthos/custom_association_proxy'

require 'acts_as_list'
require 'sunspot'
require 'sunspot_rails'
require 'delayed_job'
require 'has_scope'
