class ContentLists
  class << self
    def [](handle)
      ContentList.find_or_create_by_handle(handle.to_s)
    end

    alias method_missing []
  end
end