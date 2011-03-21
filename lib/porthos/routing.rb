module Porthos
  class Routing
    cattr_accessor :rules
    self.rules = []

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