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
                path.replace URI.unescape(path)
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
                # yield.tap do |_params|
                   params.merge!(mapping_params) if node
                   params.merge!(custom_params)
                # end
                params
              end
            end
          end
        end

        def around_generate(params, &block)
          if !params[:controller].present? or params[:controller] =~ /admin/
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
