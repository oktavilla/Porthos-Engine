require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      custom_params = {}
      matches = Porthos::Routing.recognize(path)
      matches.delete(:url).tap do |recognized_url|
        path.replace recognized_url
        custom_params.merge!(matches)
      end if matches[:url]

      node_url = path.gsub(/^\//,'')
      if node = Node.where(:url => (!node_url.blank? ? node_url : nil)).first
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

    def around_generate(params, &block)
      # unless params.delete(:_lookup) === true
      #   yield and return
      # end
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
            path_template = rule[:test].dup
            path_template.gsub!(":url", "/#{node.url}")
            rule[:constraints].except(:url).each do |key, value|
              path_template.gsub!(":#{key.to_s}", params[key]) if params[key]
            end
            path.replace(path_template)
          else
            path.replace node.url
          end
        end
      end
    end
  end
end