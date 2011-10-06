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
                  if node && node.handle && namespaced_match = Porthos::Routing::Recognize.run(path, :namespace => node.handle).first
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
            return yield
          end

          node = nil
          conditions = {
            controller: params[:controller],
            action:     params[:action]
          }

          if params[:id].present?
            conditions.merge! resource_conditions(params)
          else
            conditions.merge! handle: params[:handle]
          end

          conditions_key = conditions.to_a.sort
          node = Porthos::Routing::Cache.cached[conditions_key]
          unless node
            node = Node.limit(1).fields(:url, :resource_id, :handle).where(conditions).first
            if node
              Porthos::Routing::Cache.cached[conditions_key] = node
            end
          end

          if !node && params[:handle]
            handle_conditions = { handle: params[:handle] }
            handle_conditions_key = handle_conditions.to_a
            node = Porthos::Routing::Cache.cached[handle_conditions_key]
            unless node
              node = Node.limit(1).fields(:url, :resource_id, :handle).where(handle_conditions).first
              if node
                Porthos::Routing::Cache.cached[handle_conditions_key] = node
              end
            end
          end

          if node
            yield.tap do |result|
              path, computed_params = *result

              if node.resource_id.present? # We have a node pointing to a specific resource
                path = "/#{node.url}"
              else # Try and find a matching url structure
                rule = Porthos::Routing::Recognize.rules.find_matching_params(params)
                if rule
                  path = rule.computed_path(node, params)
                  computed_params = computed_params.except(*rule.param_keys)
                else
                  path = "/#{node.url}"
                end
              end

              computed_params.delete(:handle) if node.handle == computed_params[:handle]
              path += ".#{params[:format]}" if params[:format].present?

              result.replace [path, computed_params]
            end
          else
            yield
          end
        end

    protected

        def resource_conditions(params)
          resource = params[:id]
          if resource.kind_of?(::MongoMapper::Document) or resource.kind_of?(::ActiveRecord::Base)
            params[:id] = resource.try(:uri) || resource.to_param
            params[:handle] = resource.handle if !params[:handle] && resource.respond_to?(:handle)
            { resource_type: resource.class.to_s, resource_id: resource.id }
          else
            { resource_type: params[:controller].classify, resource_id: resource }
          end
        end

      end

    end
  end
end