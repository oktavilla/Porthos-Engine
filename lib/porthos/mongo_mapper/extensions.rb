module Porthos
  module MongoMapper
    module Extensions

      module SymbolOperator
        def to_mongo(value)
          if value.nil? || value.to_s == ''
            nil
          elsif value.kind_of?(SymbolOperator)
            {
              field: value.field,
              operator: value.operator
            }
          elsif value.is_a?(Hash)
            value
          end
        end

        def from_mongo(value)
          if !value.nil? && value.present?
            if value.kind_of?(SymbolOperator)
              value
            elsif value.is_a?(Hash) && value[:field]
              value[:field].public_send(value[:operator] || 'desc')
            else
              nil
            end
          else
            nil
          end
        end
      end

    end
  end
end

class SymbolOperator
  include Porthos::MongoMapper::Extensions::SymbolOperator
  extend Porthos::MongoMapper::Extensions::SymbolOperator
end