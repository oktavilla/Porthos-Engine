require "porthos"
require "rails"

module Porthos
  class Engine < Rails::Engine
    config.autoload_paths += Dir[Porthos.root.join('app', 'models', '{**}')]
    config.i18n.default_locale = "sv-SE"
    config.i18n.fallbacks = true

    config.use_fulltext_search = false

    config.active_record.identity_map = true

    initializer "porthos.static_assets" do |app|
      if app.config.serve_static_assets
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/assets"
      end
    end

    initializer "porthos.redirects" do |app|
      app.middleware.use Porthos::Redirects
    end

    initializer 'porthos.helpers' do |app|
      ActiveSupport.on_load :action_view do
        include PorthosApplicationHelper
      end
    end

    initializer 'porthos.authentication' do |app|
      app.middleware.use ::Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = Porthos::Authentication::UnauthorizedRequest
      end
      ActiveSupport.on_load :action_controller do
        include Porthos::Authentication::Helpers
      end
    end
  end
end