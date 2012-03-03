class PagesController < ApplicationController
  include Porthos::Public

  before_filter :only => :preview do |c|
    c.send :authenticate!
  end

  def index
    @page_template = PageTemplate.first(handle: node.handle)
    template = @page_template ? @page_template.template : PageFileTemplate.default
    @page_renderer = page_renderer(template, {
      :page_template => @page_template
    })

    respond_to do |format|
      format.html { render template: template.views.index }
      format.rss do
        if template_for_format_exists?(template.views.index, 'rss.builder')
          expires_in 1.hour, :public => true
          render template: template.views.index, layout: false
        else
          render nothing: true, status: :not_acceptable
        end
      end
    end
  end

  def show
    @page = if BSON::ObjectId.legal?(params[:id].to_s)
      Item.published.find(params[:id])
    else
      Item.published.where(uri: params[:id], handle: params[:handle]).first
    end
    raise ActiveRecord::RecordNotFound unless @page

    template = @page.template
    @page_renderer = page_renderer(template, page_template: @page.page_template, page: @page)

    if !@page.restricted? || signed_in?
      respond_to do |format|
        format.html { render :template => template.views.show }
      end
    else
      return authenticate!
    end
  end

  def preview
    @page = Item.find(params[:id])
    template = @page.page_template.template
    @page_renderer = page_renderer(template, page_template: @page.page_template, page: @page)
    respond_to do |format|
      format.html { render :template => template.views.show }
    end
  end

  def search
    filters = params[:filters] || {}
    @page_template = PageTemplate.where(handle: node.handle).first

    template = @page_template ? @page_template.template : PageTemplate.default

    search_query = params[:query] if params[:query].present?
    if search_query.present? or filters.any?
      page_template = @page_template
      @search = Page.search do
        keywords search_query
        if filters.any?
          dynamic :custom_attributes do
            filters.each do |key, value|
              with(key.to_sym, value) unless value.blank?
            end
          end
        end
        with(:is_active, true)
        with(:is_restricted, false)
        with(:page_template_id, page_template.id) if page_template
        with(:published_on).less_than Time.now
      end
      @query, @filters = params[:query], filters
    end
    respond_to do |format|
      format.html { render :template => template.views.search }
    end
  end

  def categories
    @page_template = PageTemplate.where(handle: node.handle).first
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, page_template: @page_template)

    respond_to do |format|
      format.html { render template: template.views.categories }
    end
  end

  def category
    @page_template = PageTemplate.where(handle: node.handle).first
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, page_template: @page_template)
    respond_to do |format|
      format.html { render template: template.views.category }
    end
  end

  def tagged_with
    @page_template = PageTemplate.where(handle: node.handle).first
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, page_template: @page_template)

    respond_to do |format|
      format.html { render template: template.views.tagged_with }
    end
  end

protected

  def page_renderer(template, objects = {})
    "#{template.name.camelize}Renderer::#{self.action_name.camelize}".constantize.new(self, objects)
  end

  def template_for_format_exists?(path, format)
    puts Rails.root.join("#{path}.#{format}")
    File.exists?(Rails.root.join('app', 'views', "#{path}.#{format}"))
  end

end
