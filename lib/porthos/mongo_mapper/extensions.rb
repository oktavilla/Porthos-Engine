module Porthos
  module MongoMapper
    module Extensions

      module SymbolOperator
        def to_mongo(value)
          if value.nil? || value.to_s == ''
            nil
          else
            {
              field: value.field,
              operator: value.operator
            }
          end
        end

        def from_mongo(value)
          if value.present?
            if value.kind_of?(SymbolOperator)
              value
            else
              value[:field].public_send(value[:operator])
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