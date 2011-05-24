# require "#{Rails.root}/app/views/pages/templates/default/default_page_renderer"
class PagesController < ApplicationController
  include Porthos::Public
  before_filter :require_node

  before_filter :only => :preview do |c|
    user = c.send :current_user
    raise ActiveRecord::RecordNotFound if user == :false or !user.admin?
  end

  def index
    @page_template = @node.page_template
    template = @page_template ? @page_template.template : PageFileTemplate.default
    @page_template = page_renderer(template, {
      :page_template => @page_template
    })

    respond_to do |format|
      format.html { render :template => template.views.index }
      format.rss  { render :template => template.views.index, :layout => false }
    end
  end

  def show
    @page = Page.find(params[:id]) ||
            Page.find(:uri => params[:id]) ||
            (raise ActiveRecord::RecordNotFound)
    template = @page.page_template.template
    @page_renderer = page_renderer(template, :page_template => @page.page_template, :page => @page)

    if !@page.restricted? || logged_in?
      respond_to do |format|
        format.html { render :template => template.views.show }
      end
    else
      return login_required
    end
  end

  def preview
    @page = Page.find(params[:id])
    template = @page.page_template.template
    @page_renderer = page_renderer(template, :page_template => @page.page_template, :page => @page)
    respond_to do |format|
      format.html { render :template => template.views.show }
    end
  end

  def search
    filters = params[:filters] || {}
    @page_template = @node.page_template

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
    @page_template = @node.page_template
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, :page_template => @page_template)

    respond_to do |format|
      format.html { render :template => template.views.categories }
    end
  end

  def category
    @page_template = @node.page_template
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, :page_template => @page_template)

    respond_to do |format|
      format.html { render :template => template.views.category }
    end
  end

  def tagged_with
    @page_template = @node.page_template
    template = @page_template ? @page_template.template : PageTemplate.default
    @page_renderer = page_renderer(template, :page_template => @page_template)

    respond_to do |format|
      format.html { render :template => template.views.tagged_with }
    end
  end

protected

  def page_renderer(template, objects = {})
    "#{template.name.camelize}Renderer::#{self.action_name.camelize}".constantize.new(self, objects)
  end

end
