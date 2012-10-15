module Porthos
  class Engine < Rails::Engine
    config.autoload_paths += Dir[config.root.join('app', 'models', '{**}')]
    config.i18n.default_locale = "sv-SE"
    config.i18n.fallbacks = true
    config.use_fulltext_search = false

    config.active_record.identity_map = true

    config.porthos = ::Porthos::Config

    rake_tasks do
      load Porthos.root.join("lib/tasks/porthos_tasks.rake")
    end

    initializer "porthos.redirects" do |app|
      app.middleware.use Porthos::Middleware::RedirectApp
    end

    initializer "porthos.routing_cache" do |app|
      app.middleware.insert_before ::MongoMapper::Middleware::IdentityMap, Porthos::Middleware::RoutingCache
    end

    initializer "porthos.caching_shells" do |app|
      app.middleware.use Porthos::Middleware::ShellCache
    end

    initializer "porthos.routing_filters" do |app|
      RoutingFilter.send :include, Porthos::Routing::Filters
    end

    initializer 'porthos.helpers' do |app|
      ActiveSupport.on_load :action_view do
        include Porthos::ApplicationHelper
      end
    end

    initializer 'porthos.active_record' do |app|
      ActiveSupport.on_load :active_record do
        include Porthos::ActiveRecord::Restrictions
        include Porthos::ActiveRecord::Settingable
      end
    end

    initializer 'porthos.mongo_mapper' do |app|
      ActiveSupport.on_load :mongo_mapper do
        ::SymbolOperator.send :include, Porthos::MongoMapper::Extensions::SymbolOperator
        ::MongoMapper::Document.plugin ActiveModel::Observing
        ::MongoMapper::Document.plugin Porthos::MongoMapper::Plugins::ActsAsUri
        ::MongoMapper::Document.plugin Porthos::MongoMapper::Plugins::Taggable::Plugin
      end
      config.after_initialize do
        ::Porthos.config.instantiate_observers
        ActionDispatch::Callbacks.to_prepare do
          ::Porthos.config.instantiate_observers
        end
      end
    end

    initializer 'porthos.authentication' do |app|
        app.middleware.use ::Warden::Manager do |manager|
          manager.default_strategies Porthos::Authentication::Strategies.prepared_strategies
          manager.failure_app = Porthos::Authentication::UnauthorizedRequest
        end
      ActiveSupport.on_load :action_controller do
        include Porthos::Authentication::Helpers
      end
    end
  end
end
