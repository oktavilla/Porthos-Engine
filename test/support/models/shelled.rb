require_relative '../../../lib/porthos/caching/shelled'
class Shelled
  class << self
    def after_save method
      after_save_callbacks << method
    end

    def after_save_callbacks
      @after_save_callbacks ||= []
    end
  end

  include Porthos::Caching::Shelled
  use_shell 'shell-handle'
end
