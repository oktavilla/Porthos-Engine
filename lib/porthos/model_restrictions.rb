module Porthos
  module ModelRestrictions
    
    def self.included(ar)
      ar.send :include, InstanceMethods
      ar.extend SingletonMethods
    end
    
    module InstanceMethods
      def can_be_created_by?(user)
        self.class.can_be_created_by?(user)
      end
      
      def can_be_edited_by?(user)
        self.class.can_be_edited_by?(user)
      end

      def can_be_destroyed_by?(user)
        self.class.can_be_destroyed_by?(user)
      end
    end

    module SingletonMethods
      def can_be_created_by?(user)
        true
      end
      
      def can_be_edited_by?(user)
        true
      end

      def can_be_destroyed_by?(user)
        true
      end
    end
  end
end
ActiveRecord::Base.send :include, Porthos::ModelRestrictions