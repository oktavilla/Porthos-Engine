module Porthos
  module Middleware
    class ShellCache
      def initialize(app)
        @app = app
      end

      def call(env)
        Porthos::Caching.shell_cache.clear

        @app.call(env)

      ensure
        Porthos::Caching.shell_cache.clear
      end
    end
  end
end
