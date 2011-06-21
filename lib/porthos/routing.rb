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
      attr_reader :path,
                  :constraints,
                  :controller,
                  :action

      def initialize(attrs = {})
        attrs.symbolize_keys.reverse_merge(:constraints => {}).each do |key, value|
          instance_variable_set("@#{key.to_s}".to_sym, value)
        end
      end

      def param_keys
        path.scan(/:(\w+)/).flatten.collect(&:to_sym)
      end

      def computed_path(node, params)
        [node.url, translated_path].join('/').tap do |computed_path|
          template = computed_path
          constraints.each do |key, value|
            if params[key]
              value_for_key = params[key].respond_to?(:to_param) ? params[key].to_param : params[key].to_s
              template.gsub!(":#{key.to_s}", value_for_key)
            end
          end
          template = "/#{template}" unless template[0...1] == '/'
          computed_path.replace(template)
        end
      end

      def regexp_template
        "^(.*|)/#{translated_path}".tap do |regexp_template|
          template = regexp_template
          constraints.each do |key, value|
            template.gsub!(":#{key.to_s}", value)
          end
          regexp_template.replace(template)
        end.mb_chars
      end

      def translated_path
        path.dup.tap do |translated_path|
          template = translated_path
          path.scan(/{{(\w+)}}/).flatten.each do |string|
            template.gsub!("{{#{string}}}", I18n.t(string))
          end
          translated_path.replace(template)
        end
      end
    end
    class Rules
      include Enumerable

      def initialize(rules)
        @rules = rules.collect { |r| Rule.new(r) }
      end

      def each
        @rules.each { |r| yield r }
      end

      def <<(rule)
        @rules << Rule.new(rule)
      end

      def push(args)
        @rules += args.collect { |r| Rule.new(r) }
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
        :path => '{{categories}}',
        :controller => 'pages',
        :action => 'categories'
      },
      {
        :path => "{{categories}}/:id",
        :constraints => {
          :id => '([a-z0-9\-\_\s\p{Word}]+)'
        },
        :controller => 'pages',
        :action => 'category'
      }
    ])

    # Find a rule definition that matches the path
    # Returns a hash of params
    def self.recognize(path)
      return {}.tap do |params|
        self.rules.sorted.each do |rule|
          matches = path.scan(Regexp.new(rule.regexp_template)).flatten
          next unless matches.any?
          params[:url] = matches.shift.gsub(/^\//,'')
          rule.param_keys.each_with_index do |key, i|
            params[key] = matches[i]
          end
          params[:action] = rule.action if rule.action.present?
          params[:controller] = rule.controller if rule.controller.present?
          break
        end
      end
    end
  end
end
