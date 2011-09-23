module Porthos
  module Routing

    module Recognize
      mattr_accessor :rules
      self.rules = Rules.new

      # Find a rule definition that matches the path
      # Returns a hash of params
      def self.run(path, restrictions = {})
        return self.rules.sorted.collect do |rule|
          matches = path.scan(Regexp.new(rule.regexp_template, true)).flatten
          matches.pop # remove trailing slash match
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
end