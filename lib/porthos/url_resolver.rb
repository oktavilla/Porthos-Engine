require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      if env["REQUEST_URI"] =~ /^\/admin/
        yield
      else
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
        conditions = { :controller => params[:controller], :action => params[:action] }
        index_conditions = { :controller => params[:controller], :action => 'index' }
        if params[:id].present?
          resource = params[:id]
          if resource.is_a?(ActiveRecord::Base)
            params[:id] = resource.to_param
            conditions.merge!(:resource_type => resource.class.to_s, :resource_id => resource.id)
            index_conditions.merge!(:field_set_id => resource.field_set_id) if resource.respond_to?(:field_set_id)
          else
            conditions.merge!(:resource_type => params[:controller].classify, :resource_id => resource)
          end
          node = Node.where(conditions).first || Node.where(index_conditions).first
        else
          node = Node.where(conditions.merge(:field_set_id => params[:field_set_id])).first
        end

        yield.tap do |path|
          if node
            params_keys = params.keys
            rule = Porthos::Routing.rules.sort_by { |r| r[:constraints].keys.size }.reverse.detect do |r|
              r[:constraints].except(:url).keys.all? { |key| params_keys.include?(key) }
            end
            if rule
              path_template = [node.url, rule[:path]].join('/')
              rule[:constraints].except(:url).each do |key, value|
                path_template.gsub!(":#{key.to_s}", params[key].to_s) if params[key]
              end
              path_template = "/#{path_template}" unless path_template[0...1] == '/'
              path.replace(path_template)
            else
              path.replace node.url
            end
          end
        end

      end
    end
  end
end