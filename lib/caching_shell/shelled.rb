module CachingShell
  module Shelled
    extend ActiveSupport::Concern

    included do
      after_save :touch_shell
      after_touch :touch_shell
    end

    def shell
      self.class.shell
    end

    def touch_shell
      shell.touch
    end
    private :touch_shell

    module ClassMethods
      def shell_handle handle = nil
        @shell_handle ||= handle.presence || self.to_s.pluralize.parameterize
      end

      def shell
        Shell.with_handle shell_handle
      end
    end

  end
end
