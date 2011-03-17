require 'porthos/porthos'
require 'money'
require 'will_paginate'

Money.default_currency = "SEK"

PORTHOS_ROOT = "#{Rails.root}/vendor/plugins/porthos"

ActiveRecord::Base.send :include, Porthos::ActsAsFilterable

#ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
