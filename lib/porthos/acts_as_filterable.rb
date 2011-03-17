module Porthos

  module ActsAsFilterable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def acts_as_filterable
        extend ActsAsFilterable::SingletonMethods
      end

      def available_filters
        self.scopes.keys.map { |m| m.to_s }.select do |m|
          m =~ /^filter_/
        end.map { |m| m[7..-1].to_sym }
      end

    end

    module SingletonMethods
    
      def filter(filters = {})
        current_scope = self
        filters.each do |scope, args|
          if available_filters.include?(scope.to_sym)
            args, scope_method = args.to_s.split(','), "filter_#{scope}".to_sym
            current_scope = args.any? ? self.scopes[scope_method].call(current_scope, *args) : self.scopes[scope_method].call(current_scope)
          end
        end
        current_scope
      end
    
      alias :find_with_filter :filter
    
    end
    
  end
end