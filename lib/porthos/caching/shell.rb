module Porthos
  module Caching
    class Shell
      include ::MongoMapper::Document
      set_collection_name "caching_shells"

      key :handle, String
      key :updated_at

      validates_uniqueness_of :handle

      class << self
        def with_handle handle
          shell = Caching.shell_cache.get handle

          shell = where(handle: handle).first unless shell
          shell = create handle: handle unless shell

          Caching.shell_cache.set handle, shell

          shell
        end

      end
    end
  end
end
