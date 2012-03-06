module Porthos
  module Routing
    class Resolver
      attr_reader :request_path
      attr_accessor :params, :path

      def initialize(path)
        @request_path = CGI::unescape(path) # needs CGI::unescape to remove + characters
        @node_by_url_cache = {}
        resolve
      end
      
      # Find matching nodes or ruls for the current request path
      #
      # Sets params and path depending on what we find
      def resolve
        if node = node_by_url(path_as_url)
          self.params = node_params(node)
        else
          node, self.params = recognize_path
        end

        if params.any?
          if node
            # Set path to whatver root node we have
            # This seems wrong and probably is but it works. If we set the "correct path"
            # there is a lot of fucntionality we need to take into account as path options for routes etc.
            # So, do not refactor this unless you can fix it for real
            self.path = generate_path(node_params(node), format)
            self.params[:node] = { id: node.id, url: node.url }
          else
            self.path = generate_path(params, format)
          end
          params.delete(:url) # we don't want url in returned params
        end
      end

      private
      
      # Removes format and leading slash from the request path
      #
      # Returns path string
      def path_as_url
        url = request_path.gsub(/^\//,'').gsub(/#{format}$/, '')
          url << '/' if url.blank?
        url
      end

      def format
        @format ||= File.extname(request_path)
      end
      
      # Find a node matching the current url
      #
      # This caches results in a hash in case we need multiple lookups
      # Returns instance of Node or nil if none was found
      def node_by_url(url)
        return @node_by_url_cache[url] if @node_by_url_cache[url]
        @node_by_url_cache[url] = Node.where(url: url).first
      end
      
      # Looks for matching rules and nodes from the path
      # 
      # Returns array of a node and params
      def recognize_path
        node = nil
        path_params = {}
        matched_rule = match_path

        if matched_rule && node = node_by_url(matched_rule[:url])
          if node.handle && namespaced_match = Porthos::Routing::Recognize.run(request_path, :namespace => node.handle).first
            path_params = node_params(node).merge(namespaced_match)
          else
            path_params = node ? node_params(node).merge(matched_rule) : matched_rule
          end
        end

        [node, path_params]
      end

      def match_path
        matched_rule = nil
        url = path_as_url

        Porthos::Routing::Recognize.run(request_path).each do |match|
          next unless url.start_with?(match[:url])
          matched_rule = match
          if node_by_url(match[:url])
            break
          end
        end

        matched_rule
      end

      def generate_path(params, format)
        parts = if %w(index show).include?(params[:action])
          [
            params[:controller],
            params[:action],
            CGI::escape(params[:id].to_s)
          ]
        else
          [
            params[:controller],
            CGI::escape(params[:id].to_s),
            params[:action]
          ]
        end
        parts = parts.reject(&:blank?).reject { |part| %w(index show).include?(part) }

        "/#{parts.join('/')}#{format}"
      end

      def node_params(node)
        {}.tap do |_hash|
          _hash[:handle] = node.handle if node.handle.present?
          _hash[:node] = { id: node.id, url: node.url }
          _hash[:controller] = node.controller
          _hash[:action] = node.action
          _hash[:id] = node.resource_id
        end
      end

    end
  end
end
