class ContentModule < ActiveRecord::Base
  include Porthos::ContentResource

  validates_presence_of :name, :template

  def available_templates
    @available_templates ||= self.class.find_available_templates
  end

  def has_settings?
    ContentModule.template_paths.collect do |path|
      path = File.join(path, template)
      return true if File.directory?(path) and File.exists?(File.join(path, "_settings.html.erb"))
    end
    false
  end

  def has_preview?
    ContentModule.template_paths.collect do |path|
      path = File.join(path, template)
      return true if File.directory?(path) and File.exists?(File.join(path, "_preview.html.erb"))
    end
    false
  end


  class << self

    def find_available_templates
      ContentModule.template_paths.collect do |path|
        Dir.entries(path).reject { |entry| entry.chars.first == '.' or !File.directory?(File.join(path, entry) ) }
      end.flatten.compact.uniq.sort
    end

    def template_paths
      module_paths = if File.exists?(File.join(Rails.root, '/app/views/pages/contents/modules'))
        [File.join(Rails.root, '/app/views/pages/contents/modules'), File.dirname(__FILE__) + '/../views/pages/contents/modules']
      else
        [File.dirname(__FILE__) + '/../views/pages/contents/modules']
      end
    end
  end

end
