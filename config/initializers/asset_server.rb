require 'singleton'
require 'sprockets'
# Config a Sprockets::Environment to mount as a Rack end-point. I like to use a subclass
# as it allows the config to be easily reusable. Since I use the same instance for
# all mount points I make it a singleton class. I just add this as an initializer to my
# project since it is really just configuration.
class AssetServer < Sprockets::Environment
  include Singleton

  def initialize
    super Porthos.root.join('app', 'assets')
    paths << 'admin/javascripts' << 'admin/stylesheets'
    if Rails.env.production?
      self.js_compressor = YUI::JavaScriptCompressor.new :munge => true, :optimize => true
      self.css_compressor = YUI::CssCompressor.new
    end
  end
end