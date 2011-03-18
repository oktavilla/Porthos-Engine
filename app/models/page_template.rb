require 'yaml'
require 'enumerator'
class PageTemplate
  include Comparable

  attr_reader :name,
              :handle,
              :path,
              :full_path,
              :settings

  def initialize(directory)
    @handle = directory
    @path = File.join(self.class.root_path, directory)
    @full_path = File.join(self.class.root_directory, directory)
    @template_file = File.join(full_path, 'template.yml')
    if File.exists?(@template_file)
      @settings = YAML::load(File.read(@template_file))
    else
      raise "No settings file included for the template #{directory}"
    end
    @name = settings['name'] || directory
    require File.join(@full_path, "#{directory}_renderer")
  end

  def views
    @views ||= PageTemplate::Views.new(self)
  end

  def <=>(other)
    self.handle <=> other.handle
  end

  def to_s
    name
  end

  class << self

    def all
      @all ||= Dir.entries(self.root_directory).reject { |f| f[0...1] == "." }.collect do |dir|
        self.new(dir)
      end
    end

    def root_directory
      File.join(Rails.root, 'app', 'views', root_path)
    end

    def root_path
      File.join('pages', 'templates')
    end

    def default
      self.new('default')
    end

  end

  def respond_to?(*args)
    super(*args) || !settings[args.first.to_s].blank?
  end

  def method_missing_with_settings(method, *args)
    settings[method.to_s] || method_missing_without_settings(method, *args)
  end
  alias_method_chain :method_missing, :settings

  class Views
    include Enumerable

    def initialize(template)
      @template = template
      @views = Dir.entries(@template.full_path).reject { |f| f[0...1] == "." || File.basename(f, '.*') == 'template' }
    end

    def each
      @views.each { |v| yield v }
    end

    def names
      @names ||= self.collect { |v| v.split(/\./).first.gsub(/(^\_)/, '') }
    end

    def respond_to?(*args)
      super(*args) || names.include?(args.first.to_s)
    end

    def method_missing_with_check_default(method, *args)
      _method = method.to_s
      if names.include?(_method)
        File.join(@template.path, _method)
      else
        default_template = PageTemplate.default
        if @template != default_template and default_template.views.respond_to?(method)
          default_template.views.send(method, *args)
        else
          method_missing_without_check_default(method, *args)
        end
      end
    end
    alias_method_chain :method_missing, :check_default
  end

end
