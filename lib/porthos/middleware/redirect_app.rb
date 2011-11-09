module Porthos
  module Middleware
    class RedirectApp
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env['PATH_INFO']
        unless blacklisted?(path)
          path = path[0...-1] if path.ends_with?('/')
          redirect = Redirect.first(path: URI.decode(path))
          redirect_path = redirect ? redirect['target'] : nil
        else
          redirect = false
        end
        if redirect && redirect_path
          if not env['QUERY_STRING'].blank?
            if redirect_path.include?('?')
              redirect_path.gsub!('?', "?#{env['QUERY_STRING']}&")
            else
              redirect_path << "?#{env['QUERY_STRING']}"
            end
          end
          [301, { 'Content-Type' => 'text/html', 'Location' => redirect_path }, self]
        else
          @app.call(env)
        end
      end

      def each(&block)
        ['You are being redirected.'].each(&block)
      end
    
      def blacklisted?(path)
        path.match(/\/admin($|\/)|\/assets($|\/)/) != nil
      end
      
    end
  end
end
