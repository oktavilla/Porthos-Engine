module Porthos
  module Caching
    def self.shell_cache
      @cache ||= ShellCache.instance
    end
  end
end
