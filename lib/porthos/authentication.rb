require 'warden'
require 'porthos/strategies/password.rb'
require 'porthos/strategies/rememberable.rb'

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

module Porthos
  module Authentication
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :warden, :signed_in?, :current_user
      end

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

    class UnauthorizedRequest < ActionController::Base
      def self.call(env)
        action(:redirect).call(env)
      end

      def redirect
        flash[:error] = I18n.t(:'admin.sessions.failed') if params['username'] || params['password']
        redirect_to '/admin/login'
      end
    end

    module Strategies
      mattr_accessor :registered_strategies
      self.registered_strategies = [:password, :rememberable]

      def self.prepared_strategies
        registered_strategies.each do |name|
          ::Warden::Strategies.add(name, Porthos::Authentication::Strategies.const_get(name.to_s.camelize))
        end
        registered_strategies
      end

      module Utils
        def cookies
          request.cookie_jar
        end

        def request
          @request ||= ActionDispatch::Request.new(env)
        end
      end
    end
  end
end
