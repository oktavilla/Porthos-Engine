require "porthos"
require "rails"
require "action_controller"

module Porthos
  class Engine < Rails::Engine
    config.autoload_paths += Dir[Porthos.root.join('app', 'models', '{**}')]

    initializer "static assets" do |app|
      if app.config.serve_static_assets
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end

    initializer 'helpers' do |app|
      ActionView::Base.send :include, PorthosApplicationHelper
    end
  end
end
