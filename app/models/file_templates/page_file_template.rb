require 'yaml'
class PageFileTemplate < FileTemplate

  def initialize(*args)
    super(*args)
    require File.join(@full_path, "#{@handle}_renderer")
  end

  class << self
    def root_path
      File.join('pages', 'templates')
    end
  end
end