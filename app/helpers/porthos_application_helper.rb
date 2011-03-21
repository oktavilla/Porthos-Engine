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

end
