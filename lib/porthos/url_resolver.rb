require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      excluded_path_prefixes = /(assets|admin|javascripts|stylesheets|images|graphics)/
      if env["REQUEST_URI"] =~ excluded_path_prefixes or path =~ excluded_path_prefixes
        yield
      else
        yield.tap do |params|
          unless params.any?
            path.replace(CGI::unescape(path))
            custom_params = {}
            matched_rule = nil
            url = path.gsub(/^\//,'')
            node = Node.where(url: (url.present? ? url : '/')).first
            unless node
              Porthos::Routing.recognize(path).each do |match|
                next unless url.start_with?(match[:url])
                matched_rule = match
                matched_url = match.delete(:url)
                if node = Node.where(url: matched_url).first
                  break
                end
              end
              if node and node.handle and namespaced_match = Porthos::Routing.recognize(path, :namespace => node.handle).first
                custom_params.merge!(namespaced_match)
              else
                custom_params.merge!(matched_rule)
              end
            end

            if node
              custom_params[:handle] = node.handle if node.handle.present?
              custom_params[:node] = { id: node.id, url: node.url }
              mapping_params = { controller: node.controller, action: node.action }
              mapping_params[:id] = node.resource_id if node.resource_id.present?
              path.replace('/' + mapping_params.values.reject { |part| %w(index show).include?(part) }.join('/'))
            end
            yield.tap do |_params|
              _params.merge!(mapping_params) if node
              _params.merge!(custom_params)
            end
          end
        end
      end
    end

    def around_generate(params, &block)
      if params[:controller] =~ /admin/
        yield
      else
        node = nil
        node_uri = nil
        handle = params[:handle]
        conditions = { controller: params[:controller], action: params[:action] }
        index_conditions = conditions.dup.merge(action: 'index')
        if params[:id].present?
          resource = params[:id]
          handle = resource.handle if handle.blank? and resource.respond_to?(:handle)
          if resource.kind_of?(MongoMapper::Document) or resource.kind_of?(ActiveRecord::Base)
            params[:id] = resource.to_param
            conditions.merge!(resource_type: resource.class.to_s, resource_id: resource.id)
          else
            conditions.merge!(resource_type: params[:controller].classify, resource_id: resource)
          end
          index_conditions.merge!(handle: handle)
          if node = (Node.first(conditions) || Node.first(index_conditions))
            params[:id] = resource.uri if resource.respond_to?(:uri) and resource.uri.present?
            node_uri = "/#{node.url}" if node.resource_id.present?
          end
        end
        if !node and handle.present?
          node = Node.first(handle: handle)
        end
        yield.tap do |path|
          if node
            if node_uri
              path.replace([node_uri])
            else
              rule = Porthos::Routing.rules.find_matching_params(params)
              path.replace([rule ? rule.computed_path(node, params) : "/#{node.url}"])
            end
          end
        end
      end
    end
  end
end
