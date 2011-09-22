module Porthos
  class RedirectApp
    def initialize(app)
      @app = app
    end

    def call(env)
      redirect = Redirect.first(conditions: { path: env['PATH_INFO'] })
      if redirect and (redirect_path = redirect['target'])
        if not env['QUERY_STRING'].blank?
          if redirect_path.include?('?')
            redirect_path.gsub!('?', "?#{env['QUERY_STRING']}&")
          else
            redirect_path << "?#{env['QUERY_STRING']}"
          end
        end
        [301, {'Content-Type' => 'text/html', 'Location' => redirect_path}, ['You are being redirected.']]
      else
        @app.call(env)
      end
    end
  end
end
