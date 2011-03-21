Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
module Porthos
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
require 'porthos/acts_as_filterable'
require 'Porthos/content_resource'

require 'acts_as_list'
require 'sunspot'
require 'sunspot_rails'
require 'delayed_job'
