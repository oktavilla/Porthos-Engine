require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      excluded_path_prefixes = /^\/(assets\/admin|admin|javascripts|stylesheets|images|graphics)/
      if env["REQUEST_URI"] =~ excluded_path_prefixes or path =~ excluded_path_prefixes
        yield
      else
        yield.tap do |params|
          unless params.any?
            path.replace(CGI::unescape(path))
            custom_params = {}
            node_url = path.gsub(/^\//,'')
            node = Node.where(:url => (!node_url.blank? ? node_url : nil)).first
            unless node
              matches = Porthos::Routing.recognize(path)
              node_url = matches.delete(:url)
              custom_params.merge!(matches)
              node = Node.where(:url => (!node_url.blank? ? node_url : nil)).first
            end

            if node
              mapping_params = { :controller => node.controller, :action => node.action }
              mapping_params[:handle] = node.handle if node.handle.present?
              mapping_params[:id] = node.resource_id if node.resource_id.present?
              path.replace('/' + mapping_params.values.find_all { |part| !%w(index show).include?(part) }.join('/'))
              custom_params[:node] = {
                :id => node.id,
                :url => node.url
              }
            end
            params.replace(yield.tap { |_params|
              _params.merge!(mapping_params) if node
              _params.merge!(custom_params)
            })
          end
        end
      end
    end

    def around_generate(params, &block)
      if params[:controller] =~ /admin/
        yield
      else
        node = nil
        conditions = { :controller => params[:controller], :action => params[:action] }
        index_conditions = conditions.dup.merge(:action => 'index')
        if params[:id].present?
          resource = params[:id]
          if resource.kind_of?(MongoMapper::Document) or resource.kind_of?(ActiveRecord::Base)
            params[:id] = resource.to_param
            conditions.merge!(:resource_type => resource.class.to_s, :resource_id => resource.id)
          else
            conditions.merge!(:resource_type => params[:controller].classify, :resource_id => resource)
          end
          index_conditions.merge!(:handle => params[:handle])
          node = Node.first(conditions) || Node.first(index_conditions)
        end
        if !node and params[:handle].present?
          node = Node.first(:handle => params[:handle])
        end
        yield.tap do |path|
          if node
            if node.resource_id.present?
              path.replace(["/#{node.url}"])
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
