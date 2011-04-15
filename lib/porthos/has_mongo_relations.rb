module Porthos
  module HasMongoRelations
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def to_mongo(_model)
        _model.id
      end
      def from_mongo(_id)
        find(_id)
      end
    end
  end
end
