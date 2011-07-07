module Porthos
  module Admin
    extend ActiveSupport::Concern

    module InstanceMethods
      def clear_callback
        session.delete(:create_callback) if !params[:create_callback] && session[:create_callback]
      end

      def set_current_user
        User.current = current_user if signed_in?
        yield
        User.current = nil
      end
    end

    included do
      before_filter :authenticate!
      before_filter :clear_callback
      around_filter :set_current_user
      layout 'admin/application'
    end

  end
end