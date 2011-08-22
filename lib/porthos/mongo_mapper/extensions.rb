module Porthos
  module MongoMapper
    module Extensions

      module SymbolOperator
        extend ActiveSupport::Concern

        module ClassMethods
          def to_mongo(value)
            if value.is_a?(SymbolOperator)
              value.to_mongo
            else
              typecasted = if value.is_a?(Symbol)
                self.new(value, 'desc')
              elsif value.acts_like?(:string)
                field, operator = value.to_s.split('.')
                field.present? ? self.new(field.to_sym, operator || 'desc') : nil
              elsif value.is_a?(Hash)
                value.to_options!
                if value[:field]
                  operator = value[:operator].present? ? value[:operator].to_s : 'desc'
                  self.new(value[:field].to_sym, operator)
                else
                  nil
                end
              end
              typecasted.is_a?(self) ? typecasted.to_mongo : nil
            end
          end

          def from_mongo(value)
            if value.is_a?(self)
              value
            elsif value.nil? || value.to_s == ''
              nil
            else
              value['field'].to_sym.public_send(value['operator'] || 'desc')
            end
          end
        end

        module InstanceMethods
          def to_mongo
            {
              "field" => self.field.to_s,
              "operator" => self.operator.to_s
            }
          end
        end
      end

    end
  end
end

class SymbolOperator
  include Porthos::MongoMapper::Extensions::SymbolOperator

  def ==(other)
    other.class == SymbolOperator && field == other.field && operator == other.operator
  end

end