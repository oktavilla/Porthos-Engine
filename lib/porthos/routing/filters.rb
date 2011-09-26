require 'routing_filter'
module Porthos
  module Routing
    module Filters

      class UrlResolver < RoutingFilter::Filter
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
                url = path.dup.gsub(/^\//,'')
                format = File.extname(path)
                url.gsub!(format, '') unless format.blank?
                node = Node.where(url: (url.present? ? url : '/')).first
                unless node
                  Porthos::Routing::Recognize.run(path).each do |match|
                    next unless url.start_with?(match[:url])
                    matched_rule = match
                    matched_url = match.delete(:url)
                    if node = Node.where(url: matched_url).first
                      break
                    end
                  end
                  if node and node.handle and namespaced_match = Porthos::Routing::Recognize.run(path, :namespace => node.handle).first
                    custom_params.merge!(namespaced_match)
                  elsif matched_rule
                    custom_params.merge!(matched_rule)
                  end
                end

                if node
                  custom_params[:handle] = node.handle if node.handle.present?
                  custom_params[:node] = { id: node.id, url: node.url }
                  mapping_params = { controller: node.controller, action: node.action }
                  mapping_params[:id] = node.resource_id if node.resource_id.present?
                  path.replace('/' + mapping_params.values.reject { |part| %w(index show).include?(part) }.join('/'))
                  path.replace(path + format) if format.present?
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
          if !params[:controller].present? or params[:controller] =~ /admin/
            yield
          else
            node = nil
            handle = params[:handle]
            conditions = {
              controller: params[:controller],
              action: params[:action]
            }
            index_conditions = conditions.dup.merge(action: 'index')

            if params[:id].present?
              resource = params[:id]
              handle = resource.handle if handle.blank? and resource.respond_to?(:handle)
              if resource.kind_of?(::MongoMapper::Document) or resource.kind_of?(::ActiveRecord::Base)
                params[:id] = resource.to_param
                conditions.merge!(resource_type: resource.class.to_s, resource_id: resource.id)
              else
                conditions.merge!(resource_type: params[:controller].classify, resource_id: resource)
              end
              index_conditions.merge!(handle: handle)
              if node = (Node.first(conditions) || Node.first(index_conditions))
                params[:id] = resource.uri if resource.respond_to?(:uri) and resource.uri.present?
              end
            end

            if !node and handle.present?
              node = Node.first(handle: handle)
            end

            yield.tap do |result|
              if node
                path, _params = *result

                if node.resource_id.present?
                  path = "/#{node.url}"
                else
                  if rule = Porthos::Routing::Recognize.rules.find_matching_params(params)
                    path = rule.computed_path(node, params)
                    _params = _params.except(*rule.param_keys)
                  else
                    path = "/#{node.url}"
                  end
                end

                _params.delete(:handle) if node.handle == _params[:handle]
                path += ".#{params[:format]}" if params[:format].present?

                result.replace [path, _params]
              end
            end
          end
        end
      end

    end
  end
end
