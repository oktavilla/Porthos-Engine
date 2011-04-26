module Porthos
  module Admin

    # Set remember_uri as an after_filter
    def self.included(base)
      base.send :before_filter, :authenticate!
      base.send :skip_before_filter, :remember_uri, :only => [:edit, :create, :update, :destroy, :sort]
      base.send :before_filter, :clear_callback
      base.send :layout, 'admin/application'
    end

  protected

    def clear_callback
      unless params[:create_callback]
        session[:create_callback] = nil
      end
    end

    def restfull_path_for(object, options = {})
      action = options.delete(:action)
      unless object.respond_to?(:superclass)
        base = "#{object.class.to_s.underscore}_path"
        options[:id] ||= object.id
      else
        base = "#{object.class.to_s.underscore.pluralize}_path"
      end
      url = ['admin', action, base].compact.join('_').to_sym
      self.send url, options
    end

  end
end
