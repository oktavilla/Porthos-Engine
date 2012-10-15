module Porthos
  module Middleware
    class ShellCache
      def initialize(app)
        @app = app
      end

      def call(env)
        ::CachingShell.object_cache.clear

        @app.call(env)

      ensure
        ::CachingShell.object_cache.clear
      end
    end
  end
end
