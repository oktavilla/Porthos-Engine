module Porthos
  module Middleware
    class RedirectApp
      def initialize(app)
        @app = app
      end

      def call(env)
        redirect = Redirect.first(path: env['PATH_INFO'])
        redirect_path = redirect ? redirect['target'] : nil
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

    end
  end
end
