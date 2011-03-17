require "porthos"
require "rails"
require "action_controller"

module Porthos
  class Engine < Rails::Engine
    engine_name :porthos

    initializer "static assets" do |app|
      if app.config.serve_static_assets
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end
  end
end
