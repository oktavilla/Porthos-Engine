module Porthos
  module Caching

    def self.shell_cache
      @cache ||= ShellCache.new
    end

    class ShellCache
      include Singleton

      def set key, value
        _cache[key] = value
      end

      def get key
        _cache[key]
      end

      def clear
        _cache.clear
      end

      private

      def _cache
        @_cache ||= {}
      end
    end
  end
end
