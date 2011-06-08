module Porthos
  module Public

    def self.included(controller)
      controller.send :include, ClassMethods
      controller.send :helper_method, :root_node, :root_nodes, :node, :nodes
      controller.send :helper_method, :trail, :breadcrumbs
      controller.send :layout, 'public'
    end

    module ClassMethods
      # we should overwrite login_required to render a public login view
      def require_node
        login_required if trail.detect { |n| n.restricted? } and not logged_in?
        raise ActiveRecord::RecordNotFound if trail.detect { |n| n.inactive? }
      end

      def porthos_session_id
        session[:porthos_id] ||= CGI::Session.generate_unique_id
      end

    protected

      def root_node
        @root_node ||= Node.root
      end

      def root_nodes
        @root_nodes ||= [root_node] + root_node.children
      end

      def node
        @node ||= Node.find_by_url(params[:node][:url]) or raise ActiveRecord::RecordNotFound
      end

      def nodes
        # fetch the children of the selected top level node (it later recursive renders all nodes belonging to the trail)
        @nodes ||= unless node == root_node # dont fetch children for the root node (that's all nodes dummy!)
          node_ancestors.any? ? node_ancestors.first.children : node.children
        else
          []
        end
      end

      def porthos_session_id
        session[:porthos_id] ||= ActiveSupport::SecureRandom.hex
      end

      def node_ancestors
        unless defined?(@node_ancestors)
          @node_ancestors = node.ancestors.reverse
          @node_ancestors.shift
        end
        @node_ancestors
      end

      def trail
        unless defined?(@trail)
          # fetch an ordered trail (top to bottom) of nodes
          @trail = if node_ancestors and node_ancestors.any?
            node_ancestors.dup << node
          else
            [node]
          end
        end
        @trail
      end

      def breadcrumbs
        @breadcrumbs ||= trail.collect { |n| ["/#{n.uri}", n.name] }
      end

    end
  end
end