module Porthos
  module Routing
    class Resolver
      attr_reader :request_path, :params, :path

      def initialize(path)
        @request_path = CGI::unescape(path) # needs CGI::unescape to remove + characters
        @node_by_url_cache = {}
        resolve
      end

      def resolve
        if node = node_by_url(path_as_url)
          @params = node_params(node)
        else
          node, @params = recognize_path
        end

        if @params.any?
          if node
            @path = generate_path(node_params(node), format)
            @params[:node] = { id: node.id, url: node.url }
          else
            @path = generate_path(params, format)
          end
          @params.delete(:url) # we don't want url in returned params
        end
      end

      private

      def path_as_url
        url = request_path.gsub(/^\//,'').gsub(/#{format}$/, '')
          url << '/' if url.blank?
        url
      end

      def format
        @format ||= File.extname(request_path)
      end

      def node_by_url(url)
        return @node_by_url_cache[url] if @node_by_url_cache[url]
        @node_by_url_cache[url] = Node.where(url: url).first
      end

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
