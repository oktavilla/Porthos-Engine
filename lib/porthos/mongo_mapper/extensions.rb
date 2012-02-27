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
              typecasted = if value.acts_like?(:string)
                field, operator = value.to_s.split('.')
                field.present? ? self.new(field.to_sym, operator) : nil
              elsif value.is_a?(Hash)
                value.to_options!
                if value[:field] && value[:operator]
                  self.new(value[:field].to_sym, value[:operator].to_s)
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
              field, operator = value.split('.')
              field && operator ? self.new(field.to_sym, operator) : nil
            end
          end
        end

        def to_mongo
          "#{field.to_s}.#{operator}"
        end

      end

    end
  end
end
