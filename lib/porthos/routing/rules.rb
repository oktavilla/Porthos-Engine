module Porthos
  module Routing

    class Rules
      include Enumerable

      def initialize(rules = [])
        @default_options = {}
        @rules = rules.map { |r| Rule.from_hash(r) }
      end

      def reset!
        @rules = []
      end

      def size
        @rules.size
      end

      def last
        @rules[size-1]
      end

      def each
        @rules.each { |r| yield r }
      end

      def <<(rule)
        @rules << Rule.from_hash(rule)
      end

      def push(args)
        if args.respond_to?(:map)
          @rules += args.map { |r| Rule.from_hash(r) }
        else
          self.push [args]
        end
      end

      def with(options = {}, &block)
        @default_options = options
        instance_exec(&block)
        @default_options = {}
      end

      def match(path, options)
        self << { :path => path }.tap do |new_rule|
          new_rule.merge!(@default_options)
          new_rule.merge!(options.delete(:to))
          new_rule.merge!(options)
        end
      end

      def draw(&block)
        instance_exec(&block)
      end

      def sorted
       sort_by { |r| (r.constraints ? r.constraints.keys.size : 0)+r.path.size }.reverse
      end

      def find_matching_params(params)
        param_keys = params.keys
        sorted.detect do |rule|
          (rule.action.blank? || rule.action == params[:action]) and
          (rule.controller.blank? || rule.controller == params[:controller]) and
          rule.constraints.keys.all? { |key| param_keys.include?(key) }
        end
      end

    end

  end
end