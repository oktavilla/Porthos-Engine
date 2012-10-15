require_relative '../../../lib/caching_shell'
module StoreCallbacks
  extend ActiveSupport::Concern

  module ClassMethods
    def after_save method
      after_save_callbacks << method
    end

    def after_save_callbacks
      @after_save_callbacks ||= []
    end
  end

end

class Shelled
  include StoreCallbacks
  include CachingShell::Shelled
end

class NamedShelled
  include StoreCallbacks
  include CachingShell::Shelled

  shell_handle 'a-handle'
end
