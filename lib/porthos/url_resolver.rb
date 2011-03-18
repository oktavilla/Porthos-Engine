require 'routing_filter'
module RoutingFilter
  class UrlResolver < Filter
    def around_recognize(path, env, &block)
      yield.tap do |params|
        if node = Node.find_by_url(path)
          params[:controller] = node.controller
          params[:action]     = node.action
          params[:id]         = node.resource_id if node.resource_id.present?
        end
      end
    end

    def around_generate(params, &block)
      yield
    end
  end
end