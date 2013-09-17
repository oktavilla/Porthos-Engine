Journey::Router.class_eval do
  def find_routes_with_resolver env
    path, filter_parameters = env["PATH_INFO"], {}
    matches = find_routes_without_filtering(env)

    if matches.empty?
      excluded_path_prefixes = %w[/assets /admin /javascripts /stylesheets /images /graphics]
      if !path.starts_with?(*excluded_path_prefixes)
        if route = Porthos::Routing::Resolver.new(path)
          path.replace(route.path) if route.path
          filter_parameters.merge!(route.params)
          matches = find_routes_without_filtering(env).map do |match, parameters, route|
            [ match, parameters.merge(filter_parameters), route ]
          end
        end
      end
    end

    matches
  end
  alias_method :find_routes, :find_routes_with_resolver # reset routing-filtes aliasing
end
