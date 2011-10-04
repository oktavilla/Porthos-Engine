module Porthos
  module Middleware
    class RoutingCache

      def initialize(app)
        @app = app
      end

      def call(env)
        Porthos::Routing::Cache.clear
        @app.call(env)
      ensure
        Porthos::Routing::Cache.clear
      end

    end
  end
end
