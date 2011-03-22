module PorthosApplicationHelper

  def page_id
    @page_id ||= controller.class.to_s.underscore.gsub(/_controller$/, '').gsub(/admin\//, '')
    ' id="'+@page_id+'_view"'
  end

  def page_class(css_class = false)
    body_class = []
    body_class << css_class   if css_class
    body_class << @page_class if @page_class
    body_class << controller.action_name.underscore
    if Rails.env.development?
      body_class << 'debug' if params[:debug]
      body_class << 'grid' if params[:grid]
    end
    ' class="'+body_class.join(" ")+'"' if body_class.size > 0
  end

  def body_attributes
    page_id + page_class
  end

  def flash_messages(type = "")
    if type.blank?
      flash.collect do |type, message|
        content_tag('p', message, :class => "flash #{type}")
      end.join("\n")
    elsif flash[type.to_sym]
      content_tag('p', flash[type.to_sym], :class => "flash #{type}")
    end
  end

  def installation_specific_stylesheet_link_tag
    path = File.join(Rails.root, 'public/stylesheets/porthos_extensions.css')
    stylesheet_link_tag(js_file) if File.exists?(path)
  end

  # RIPPED FROM rails_admin (https://github.com/sferik/rails_admin)
  # A Helper to load from a CDN but with fallbacks in case the primary source is unavailable
  # The best of both worlds - fast clevery cached service from google when available and the
  # ability to work offline too.
  #
  # @example Loading jquery from google
  #   javascript_fallback "http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js",
  #     "/javascripts/jquery-1.4.3.min.js",
  #     "typeof jQuery == 'undefined'"
  # @param [String] primary a string to be passed to javascript_include_tag that represents the primary source e.g. A script on googles CDN.
  # @param [String] fallback a path to the secondary javascript file that is (hopefully) more resilliant than the primary.
  # @param [String] test a test written in javascript that evaluates to true if it is necessary to load the fallback javascript.
  # @reurns [String] the resulting html to be inserted into your page.
  def javascript_fallback(primary, fallback, test)
    html = javascript_include_tag( primary )
    html << "\n" << content_tag(:script, :type => "text/javascript") do
      %Q{
          if (#{test}) {
            document.write(unescape("%3Cscript src='#{fallback}' type='text/javascript'%3E%3C/script%3E"));
          }
      }.gsub(/^ {8}/, '').html_safe
    end
    html+"\n"
  end
end
