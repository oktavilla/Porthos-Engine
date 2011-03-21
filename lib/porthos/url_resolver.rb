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

      if node = Node.find_by_url(path)
        mapping_params = { :controller => node.controller, :action => node.action }
        mapping_params[:id] = node.resource_id if node.resource_id.present?
        path.replace('/' + mapping_params.values.find_all { |part| !%w(index show).include?(part) }.join('/'))
      end

      yield.tap do |params|
        params.merge!(custom_params)
        params.merge!(mapping_params) if node
      end
    end

    def around_generate(params, &block)
      conditions = { :controller => params[:controller], :action => params[:action] }
      params[:id].tap do |resource|
        if resource.is_a?(ActiveRecord::Base)
          conditions.merge!(:resource_type => resource.class.to_s, :resource_id => resource.id)
        else
          conditions.merge!(:resource_type => params[:controller].classify, :resource_id => resource)
        end
      end if params[:id].present?

      yield.tap do |path|
        if node = Node.where(conditions).first
          path.replace node.url
        end
      end
    end
  end
end