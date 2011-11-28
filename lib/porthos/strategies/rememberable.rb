module Porthos
  module Authentication
    module Strategies
      class Rememberable < ::Warden::Strategies::Base
        include Utils

        def valid?
          cookies.signed[cookie_name].present?
        end

        def authenticate!
          token = cookies.signed[cookie_name]
          if token.present? and user = User.where(:remember_me_token => token).first
            success!(user)
          else
            cookies.signed[cookie_name] = nil
            fail!("Could not log in")
          end
        end

        def cookie_name
          Rememberable.cookie_name
        end

        def self.cookie_name
          'remember_me'
        end
      end
    end
  end
end

Warden::Manager.before_logout do |user, auth, opts|
  if user
    user.update_attribute :remember_me_token, nil
  end
end
