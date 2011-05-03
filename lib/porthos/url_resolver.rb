require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      excluded_path_prefixes = /^\/(assets\/admin|admin|javascripts|stylesheets|images|graphics)/
      if env["REQUEST_URI"] =~ excluded_path_prefixes or path =~ excluded_path_prefixes
        yield
      else
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
          mapping_params[:id] = node.resource_id if node.resource_id.present?
          path.replace('/' + mapping_params.values.find_all { |part| !%w(index show).include?(part) }.join('/'))
          custom_params[:node] = {
            :id => node.id,
            :url => node.url
          }
        end
        yield.tap do |params|
          params.merge!(mapping_params) if node
          params.merge!(custom_params)
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
          if resource.class.include?(MongoMapper::Document)
            params[:id] = resource.to_param
            conditions.merge!(:resource_type => resource.class.to_s, :resource_id => resource.id)
            if resource.respond_to?(:field_set_id)
              index_conditions.merge!(:field_set_id => resource.field_set_id)
            else
              index_conditions.merge!(:field_set_id => params[:field_set_id])
            end
          else
            conditions.merge!(:resource_type => params[:controller].classify, :resource_id => resource)
            index_conditions.merge!(:field_set_id => params[:field_set_id])
          end
          node = Node.where(conditions).first || Node.where(index_conditions).first
        else
          node = Node.where(conditions.merge(:field_set_id => params[:field_set_id])).first
        end
        yield.tap do |path|
          if node
            if node.resource_id.present?
              path.replace("/#{node.url}")
            else
              rule = Porthos::Routing.rules.find_matching_params(params)
              path.replace(rule ? rule.computed_path(node, params) : "/#{node.url}")
            end
          end
        end
      end
    end
  end
end
