require_relative 'caching_shell/object_cache'
require_relative 'caching_shell/shell'
require_relative 'caching_shell/shelled'
module CachingShell
  def self.object_cache
    @object_cache ||= ObjectCache.instance
  end
end
