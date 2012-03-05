require 'routing_filter'
require 'porthos/routing/inject_find_routes_filter'

module Porthos
  module Routing
    module Filters

      class UrlResolver < RoutingFilter::Filter

        def around_generate(params, &block)
          if ! params[:controller].present? || params[:controller] =~ /admin/
            return yield
          end

          node = nil
          if params[:id].present?
            node = find_by_resource(params)
          end

          unless node
            node = find_by_context({
              controller: params[:controller],
              action:     params[:action],
              handle:     params[:handle]
            })
          end

          if !node && params[:handle]
            node = find_by_context({ :handle => params[:handle] })
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

              computed_params.delete(:handle)
              path += ".#{params[:format]}" if params[:format].present?

              result.replace [path, computed_params]
            end
          else
            yield
          end
        end

    protected

        def find_by_resource(params)
          resource = params[:id]
          resource_params = {
            :controller => params[:controller],
            :action => params[:action]
          }

          if resource.kind_of?(::MongoMapper::Document) or resource.kind_of?(::ActiveRecord::Base)
            params[:id] = resource.respond_to?(:uri) ? (resource.uri || resource.to_param) : resource.to_param
            params[:handle] = resource.handle if !params[:handle] && resource.respond_to?(:handle)
            
            resource_params[:resource_type] = resource.class.to_s
            resource_params[:resource_id] = resource.id.to_s
          else
            resource_params[:resource_type] = params[:controller].classify
            resource_params[:resource_id] = resource.to_s
          end
          Porthos::Routing::Cache.resource_nodes[resource_params.sort]
        end
        
        def find_by_context(conditions = {})
          cache_key = conditions.sort
          node = Porthos::Routing::Cache.cached.fetch(cache_key, 'NoCache')
          if node == 'NoCache'
            Node.limit(1).fields(:url, :resource_id, :handle).where(conditions).first.tap do |node|
              Porthos::Routing::Cache.cached[cache_key] = node
            end
          else
            node
          end
        end

      end
    end
  end
end
