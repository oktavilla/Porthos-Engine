module Porthos
  module Routing
    # A rule is a hash with three keys
    # :test => Regexp to match the path
    # :matches => Array of names (param keys) for each match for the path regexp.
    # The first match should always be "url" (anything) before the params
    # :controller => The controller name for which this rule applies to
    # Example:
    #   {
    #     :test => /(^.*)\/(\d{4})\-(\d{2})\-(\d{2})/,
    #     :matches => ['url', 'year', 'month', 'day'],
    #     :controller => 'test_posts'
    #   }
    mattr_accessor :rules
    class Rule
      include Comparable
      attr_accessor :path,
                    :constraints,
                    :controller,
                    :action,
                    :namespace,
                    :prefix

      def <=>(other_rule)
        self.compare_string <=> other_rule.compare_string
      end

      def initialize(attrs = {})
        attrs.symbolize_keys.reverse_merge(:constraints => {}).each do |key, value|
          instance_variable_set("@#{key.to_s}".to_sym, value)
        end
      end

      def match?(attrs)
        attrs.each do |key, value|
          "@#{key.to_s}".to_sym.tap do |variable_name|
            return false if !instance_variables.include?(variable_name) or
              instance_variable_get(variable_name) != value
          end
        end
        true
      end

      def param_keys
        @param_keys ||= path.scan(/:(\w+)/).flatten.map(&:to_sym)
      end

      def computed_path(node, params)
        [node.url, translated_path].join('/').tap do |computed_path|
          template = computed_path
          constraints.each do |key, value|
            if params[key]
              value_for_key = if params[key].respond_to?(:to_param)
                params[key].to_param
              else
                params[key].to_s
              end
              template.gsub!(":#{key.to_s}", value_for_key)
            end
          end
          template = "/#{template}" unless template[0...1] == '/'
          computed_path.replace(template)
        end
      end

      def regexp_template
        @regexp_template ||= "^(#{regexp_prefix})/#{translated_path}(\/|)$".tap do |regexp_template|
          template = regexp_template
          constraints.each do |key, value|
            template.gsub!(":#{key.to_s}", value)
          end
          regexp_template.replace(template)
        end.mb_chars
      end

      def regexp_prefix
        @regexp_prefix ||= prefix ? "/#{translate(prefix)}" : '.*|'
      end

      def translated_path
        @translated_path ||= translate(path)
      end

    private

      def compare_string
        @compare_string ||= "#{path}-#{controller}-#{action}"
      end

      def translate(i18n_string)
        i18n_string.dup.tap do |translated_string|
          template = translated_string
          i18n_string.scan(/\%{([\w\.]+)}/).flatten.each do |string|
            template.gsub!("%{#{string}}", I18n.t("routes.#{string}"))
          end
          translated_string.replace(template)
        end
      end

      class << self
        def from_hash(attrs)
          attrs.kind_of?(Hash) ? new(attrs) : attrs
        end
      end

    end

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

    self.rules = Rules.new([

      {
        :path => ":id",
        :constraints => {
          :id => '([a-z0-9\-\_]+)'
        },
        :controller => 'pages',
        :action => 'show'
      },
      {
        :path => ":year/:month/:day/:id",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})',
          :id => '([a-z0-9\-\_]+)'
        },
        :controller => 'pages',
        :action => 'show'
      },
      {
        :path => ":year/:month/:day",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})',
          :day => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :path => ":year/:month",
        :constraints => {
          :year => '(\d{4})',
          :month => '(\d{2})'
        },
        :controller => 'pages'
      },
      {
        :path => ":year",
        :constraints => {
          :year => '(\d{4})'
        },
        :controller => 'pages'
      },
      {
        :path => '%{categories}',
        :controller => 'pages',
        :action => 'categories'
      },
      {
        :path => "%{categories}/:id",
        :constraints => {
          :id => '([a-z0-9\-\_\s\p{Word}]+)'
        },
        :controller => 'pages',
        :action => 'category'
      }
    ])

    # Find a rule definition that matches the path
    # Returns a hash of params
    def self.recognize(path, restrictions = {})
      return self.rules.sorted.collect do |rule|
        matches = path.scan(Regexp.new(rule.regexp_template)).flatten
        next unless (matches.any? and rule.match?(restrictions))
        {}.tap do |params|
          params[:url] = matches.shift.gsub(/^\//,'')
          rule.param_keys.each_with_index do |key, i|
            params[key] = matches[i]
          end
          params[:action] = rule.action if rule.action.present?
          params[:controller] = rule.controller if rule.controller.present?
          params[:namespace] = rule.namespace if rule.namespace.present?
        end
      end.compact
    end
  end
end
