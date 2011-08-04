module Porthos
  module Public
    extend ActiveSupport::Concern

    module InstanceMethods

      def root_node
        @root_node ||= Node.root
      end

      def root_nodes
        @root_nodes ||= [root_node] + root_node.children
      end

      def node
        @node ||= params[:node] ? Node.find_by_id(params[:node][:id]) : nil
      end

      def nodes
        # fetch the children of the selected top level node (it later recursive renders all nodes belonging to the trail)
        @nodes ||= unless node == root_node # dont fetch children for the root node (that's all nodes dummy!)
          node_ancestors.any? ? node_ancestors.first.children : node.children
        else
          []
        end
      end

      def trail
        unless defined?(@trail)
          # fetch an ordered trail (top to bottom) of nodes
          @trail = if node && node.ancestors.any?
            node.ancestors.dup.tap do |ancestors|
              ancestors.shift
              ancestors << node
            end
          else
            [node]
          end
        end
        @trail
      end

      def breadcrumbs
        @breadcrumbs ||= trail.map { |n| ["/#{n.url}", n.name] }
      end

    end

    included do
      helper_method :root_node, :root_nodes, :nodes, :node
      helper_method :trail, :breadcrumbs
      layout 'public'
    end

  end
end
