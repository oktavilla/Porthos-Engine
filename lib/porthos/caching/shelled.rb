module Porthos
  module Caching
    module Shelled
      extend ActiveSupport::Concern

      included do
        after_save :touch_shell
      end

      def shell
        self.class.shell
      end

      def touch_shell
        shell.touch
      end
      private :touch_shell

      module ClassMethods
        def use_shell handle
          @shell_handle = handle
        end

        def shell
          Shell.with_handle @shell_handle
        end
      end

    end
  end
end
