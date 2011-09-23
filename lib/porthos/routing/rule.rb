module Porthos
  module Routing

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
        @regexp_template ||= "^(.*#{regexp_prefix}|#{regexp_prefix})/#{translated_path}(/|)$".tap do |regexp_template|
          template = regexp_template
          constraints.each do |key, value|
            template.gsub!(":#{key.to_s}", value)
          end
          regexp_template.replace(template)
        end.mb_chars
      end

      def regexp_prefix
        @regexp_prefix ||= prefix ? "/#{translate(prefix)}" : ''
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

  end
end