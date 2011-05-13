module Porthos
  module DatumMethods
    extend ActiveSupport::Concern

    included do
      key :label, String
      key :handle, String
      key :required, Boolean, :default => lambda { false }
      key :position, Integer

      before_validation :parameterize_handle
      before_save :move_to_list_bottom

      validates_presence_of :label
      validates_presence_of :handle, :if => proc { |d| d.require_handle? }
      validate :uniqueness_of_handle, :if => proc { |d| d.require_handle? }
    end

    module InstanceMethods

    protected

      def require_handle?
        @require_handle ||= _parent_document && !(_parent_document.class.to_s.match(/ContentBlock/))
      end

      def uniqueness_of_handle
        if _parent_document && _parent_document.respond_to?(:data) && _parent_document.data.detect { |d| d.id != self.id && d.handle == self.handle }
          errors.add(:handle, :taken)
        end
      end

      def parameterize_handle
        self.handle = handle.parameterize('_') if handle.present?
      end

      def move_to_list_bottom
        if position.blank? && _parent_document && _parent_document.respond_to?(:data)
          siblings = _parent_document.data.find_all { |d| d.position.present? && d.id != self.id }
          self.position = siblings.any? ? siblings.sort_by(&:position).last.position + 1 : 1
        end
      end
    end
  end
end