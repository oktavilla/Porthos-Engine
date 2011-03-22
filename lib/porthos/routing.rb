module Porthos
  class Routing
    # A rule is a hash with three keys
    # :test => Regexp to match the path
    # :matches => Array of names (param keys) for each match for the path regexp.
    # The first match should always be "url" (anything) before the params
    # :scope => The controller name for which this rule applies to
    # Example:
    #   {
    #     :test => /(^.*)\/(\d{4})\-(\d{2})\-(\d{2})/,
    #     :matches => ['url', 'year', 'month', 'day'],
    #     :scope => 'test_posts'
    #   }
    cattr_accessor :rules
    self.rules = []

    # Find a rule definition that matches the path
    # Returns a hash of params
    def self.recognize(path)
      return {}.tap do |params|
        self.rules.each do |rule|
          matches = path.match(rule[:test]).to_a
          next unless matches.any?
          matches.shift
          rule[:matches].each_with_index do |param, i|
            params[param.to_sym] = matches[i]
          end
        end
      end
    end

  end
end