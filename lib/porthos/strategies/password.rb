module Porthos
  module Authentication
    module Strategies
      class Password < ::Warden::Strategies::Base
        def valid?
          params['username'] || params['password']
        end

        def authenticate!
          u = User.authenticate(params['username'], params['password'])
          u.nil? ? fail!("could not log in") : success!(u)
        end
      end
    end
  end
end
