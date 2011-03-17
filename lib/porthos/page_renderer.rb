module Porthos
  class PageRenderer

    class_inheritable_accessor :available_methods
    self.available_methods = []

    def self.register_methods(*methods)
      self.available_methods.push *methods
    end

    attr_reader :params
    attr_reader :field_set

    def initialize(field_set, params)
      @field_set = field_set
      @params = params
      self.available_methods.each { |m| self.send(m) } # pre fetch everything before render time
      self
    end

    def layout_class
      @page_class ||= @field_set.handle
    end

    def title
      @title ||= @field_set.title
    end

    def page_id
      'pages-index'
    end

    register_methods :layout_class, :title, :page_id
  end
end