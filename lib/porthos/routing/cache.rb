module Porthos
  module Routing
    module Cache
      def self.cached
        @cached ||= {}
      end

      def self.resource_nodes
        return @resource_nodes if @resource_nodes && @resource_nodes.any?
        nodes = Node.where({
          :resource_id.ne => nil
        }).fields(:url, :controller, :action, :resource_type, :resource_id, :handle).all
        
        @resource_nodes = {}
        nodes.each do |node|
          @resource_nodes[node.routing_cache_key] = node
        end

        @resource_nodes
      end

      def self.clear
        self.cached.clear
        self.resource_nodes.clear
      end
    end
  end
end
