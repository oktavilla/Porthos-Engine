module Porthos
  class PageRenderer

    class_attribute :_available_methods
    self._available_methods = {}

    def self.register_methods(*methods)
      self._available_methods[self.name] = [] if self.available_methods.empty?
      self._available_methods[self.name].push *methods
    end

    def self.available_methods
      self._available_methods[self.name] || []
    end

    class_attribute :required_objects
    self.required_objects = [:page_template]

    attr_reader :controller,
                :params,
                :objects

    def initialize(controller, objects = {})
      @controller = controller
      @params     = controller.params
      @objects    = objects.to_options
      validate_required_objects
      create_instance_variables_for_objects
      self.class.available_methods.each { |m| self.send(m) } # pre fetch everything before render time
      after_initialize
      self
    end

    def layout_class
      @layout_class ||= @page_template.handle
    end

    def title
      @title ||= @page_template.title
    end

    def page_id
      'pages-index'
    end

    def create_instance_variables_for_objects
      objects.each do |key, object|
        self.class.send(:attr_reader, key)
        instance_variable_set("@#{key.to_s}".to_sym, object)
      end
    end

  protected

    def after_initialize
    end

    def validate_required_objects
      object_keys = @objects.keys
      self.class.required_objects.each do |object_name|
        raise "Missing required object #{object_name.to_s}" unless object_keys.include?(object_name)
      end
    end

  end
end
