require 'warden'
Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

Warden::Strategies.add(:password) do
  def valid?
    params['username'] || params['password']
  end

  def authenticate!
    u = User.authenticate(params['username'], params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

module Porthos
  module Authentication
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :warden, :signed_in?, :current_user
      end

      module InstanceMethods
        def warden
          env['warden']
        end

        def signed_in?(*args)
          warden.authenticated?(*args)
        end

        def current_user(*args)
          warden.user(*args)
        end

        def sign_in(*args)
          warden.set_user(*args)
        end

        def sign_out(*args)
          warden.logout(*args)
        end

        def authenticate(*args)
          warden.authenticate(*args)
        end

        def authenticate!(*args)
          warden.authenticate!(*args)
        end
      end
    end

    class UnauthorizedRequest < ActionController::Base
      def self.call(env)
        action(:redirect).call(env)
      end

      def redirect
        flash[:error] = I18n.t(:'admin.sessions.failed') if params['username'] || params['password']
        redirect_to admin_login_path
      end
    end
  end
end