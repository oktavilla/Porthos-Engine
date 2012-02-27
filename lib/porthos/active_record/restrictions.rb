module Porthos
  module ActiveRecord
    module Restrictions
      extend ActiveSupport::Concern

      def can_be_created_by?(user)
        self.class.can_be_created_by?(user)
      end

      def can_be_edited_by?(user)
        self.class.can_be_edited_by?(user)
      end

      def can_be_destroyed_by?(user)
        self.class.can_be_destroyed_by?(user)
      end

      module ClassMethods
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
end
