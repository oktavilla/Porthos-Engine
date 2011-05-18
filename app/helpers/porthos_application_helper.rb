module PorthosApplicationHelper

  def previous_view_path(default_path = '/')
    if params[:return_to]
      params[:return_to]
    elsif session[:last_viewed] and session[:last_viewed] != request.fullpath
      session[:last_viewed]
    else
      default_path
    end
  end

  def admin_assets_path_with_session_key(arguments = {})
    session_key = Rails.application.config.session_options[:key]
    admin_assets_path({session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token}.merge(arguments))
  end

  def nested_list_of(collection, options = {}, html_options = {}, &block)
    options = {
      :expand_all     => false,
      :allow_inactive => false,
      :first_level    => true,
      :node_class     => collection.first.class.to_s.underscore,
      :end_points     => [],
      :trail          => [],
      :except         => [],
      :trailed_class  => 'trailed'
    }.merge(options)

    html_options = {
      :id => collection.first.class.to_s.underscore.pluralize
    }.merge(html_options)

    first_level = options.delete(:first_level)
    if first_level
      if options[:end_points]
        options[:end_points] = [options[:end_points]] unless options[:end_points].is_a?(Array)
        options[:end_points].collect { |item| options[:trail] += (item.ancestors << item) }
      end
    end
    html_options.delete(:id) unless first_level

    ret = collection.collect do |item|
      next if (item.respond_to?(:access_status) and item.access_status == 'inactive') and not options[:allow_inactive] == true
      next if item == options[:except] || (options[:except].respond_to?(:include?) && options[:except].include?(item))
      in_trail = options[:trail].include?(item)
      rendered_item = capture(item, &block)
      if (options[:expand_all] and item.children.any?) or ( in_trail and item.children.any? )
        rendered_item += nested_list_of(item.children, options.merge({ :first_level => false }), &block)
      end
      if item.respond_to?(:access_status)
        status_class = unless in_trail
          item.access_status
        else
          "#{item.access_status} #{options[:trailed_class]}"
        end
      end
      node_container_options = {
        :class => [
          options[:node_class],
          status_class
        ].join(" ")
      }
      if options[:node_id].nil?
        node_container_options[:id] = "#{item.class.to_s.underscore}_#{item.id}"
      elsif not options[:node_id].blank?
        node_container_options[:id] = "#{options[:node_id]}_#{item.id}"
      end

      content_tag('li', rendered_item, node_container_options)
    end.join("\n").html_safe

    #list = content_tag('ul', ret, html_options)
    #first_level ? concat(list) : list
    content_tag('ul', ret, html_options)
  end

  def page_id
    @page_id ||= controller.class.to_s.underscore.gsub(/_controller$/, '').gsub(/admin\//, '')
    ' id="'+@page_id+'_view"'.html_safe
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
    ' class="'+body_class.join(" ")+'"'.html_safe if body_class.size > 0
  end

  def body_attributes
    "#{page_id}#{page_class}".html_safe
  end

  def flash_messages(type = "")
    if type.blank?
      flash.collect do |type, message|
        content_tag('p', message, :class => "flash #{type}", :id => 'flash')
      end.join("\n").html_safe
    elsif flash[type.to_sym]
      content_tag('p', flash[type.to_sym], :class => "flash #{type}", :id => 'flash').html_safe
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
