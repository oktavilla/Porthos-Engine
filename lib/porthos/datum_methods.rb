module Porthos
  module DatumMethods
    extend ActiveSupport::Concern

    included do
      key :label, String
      key :handle, String
      key :required, Boolean, :default => lambda { false }
      key :position, Integer

      before_validation :parameterize_handle
      before_validation :move_to_list_bottom

      validates_presence_of :label
      validates_presence_of :handle, :if => proc { |d| d.require_handle? }
      validate :uniqueness_of_handle, :if => proc { |d| d.require_handle? }
    end

    module InstanceMethods

    protected

      def in_list?
        _parent_document && _parent_document.respond_to?(list_name)
      end

      def list_name
        _parent_document.kind_of?(Template) ? 'datum_templates' : 'data'
      end

      def require_handle?
        @require_handle ||= _parent_document && !(_parent_document.class.to_s.match(/ContentBlock/))
      end

      def uniqueness_of_handle
        if in_list? && _parent_document.send(list_name).detect { |d| d.id != self.id && d.handle == self.handle }
          errors.add(:handle, :taken)
        end
      end

      def parameterize_handle
        self.handle = handle.parameterize('_') if handle.present?
      end

      def move_to_list_bottom
        if position.blank? && in_list?
          siblings = _parent_document.send(list_name).find_all { |d| d.position.present? && d.id != self.id }
          self.position = siblings.any? ? siblings.sort_by(&:position).last.position + 1 : 1
        end
      end
    end
  end
end