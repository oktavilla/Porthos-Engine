require 'porthos/porthos'

PORTHOS_ROOT = "#{Rails.root}/vendor/plugins/porthos"

ActiveRecord::Base.send :include, Porthos::ActsAsFilterable