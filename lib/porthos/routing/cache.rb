module Porthos
  module Routing
    module Cache
      def self.cached
        @cached ||= {}
      end

      def self.clear
        self.cached.clear
      end
    end
  end
end
