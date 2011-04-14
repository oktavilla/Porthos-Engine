module Porthos
  class Redirects
    def initialize(app)
      @app = app
    end

    def call(env)
      redirect = Redirect.connection.select_value("SELECT target FROM redirects WHERE path = '#{env['PATH_INFO']}' LIMIT 1")
      if redirect.present?
        if not env['QUERY_STRING'].blank?
          if redirect.include?('?')
            redirect.gsub!('?', "?#{env['QUERY_STRING']}&")
          else
            redirect << "?#{env['QUERY_STRING']}"
          end
        end
        [301, {'Content-Type' => 'text/html', 'Location' => redirect}, ['You are being redirected.']]
      else
        @app.call(env)
      end
    end
  end
end
