# require "#{Rails.root}/app/views/pages/templates/default/default_page_renderer"
class PagesController < ApplicationController
  include Porthos::Public
  before_filter :require_node

  before_filter :only => :preview do |c|
    user = c.send :current_user
    raise ActiveRecord::RecordNotFound if user == :false or !user.admin?
  end

  def index
    @field_set = @node.field_set
    template = @field_set ? @field_set.template : PageTemplate.default
    @page_renderer = page_renderer(template, {
      :field_set => @field_set
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
    template = @page.field_set.template
    @page_renderer = page_renderer(template, :field_set => @page.field_set, :page => @page)

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
    template = @page.field_set.template
    @page_renderer = page_renderer(template, :field_set => @page.field_set, :page => @page)
    respond_to do |format|
      format.html { render :template => template.views.show }
    end
  end

  def search
    filters = params[:filters] || {}
    @field_set = @node.field_set

    template = @field_set ? @field_set.template : PageTemplate.default

    search_query = params[:query] if params[:query].present?
    if search_query.present? or filters.any?
      field_set = @field_set
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
        with(:field_set_id, field_set.id) if field_set
        with(:published_on).less_than Time.now
      end
      @query, @filters = params[:query], filters
    end
    respond_to do |format|
      format.html { render :template => template.views.search }
    end
  end

  def categories
    @field_set = @node.field_set
    template = @field_set ? @field_set.template : PageTemplate.default
    @page_renderer = page_renderer(template, :field_set => @field_set)

    respond_to do |format|
      format.html { render :template => template.views.categories }
    end
  end

  def category
    @field_set = @node.field_set
    template = @field_set ? @field_set.template : PageTemplate.default
    @page_renderer = page_renderer(template, :field_set => @field_set)

    respond_to do |format|
      format.html { render :template => template.views.category }
    end
  end

  def tagged_with
    @field_set = @node.field_set
    template = @field_set ? @field_set.template : PageTemplate.default
    @page_renderer = page_renderer(template, :field_set => @field_set)

    respond_to do |format|
      format.html { render :template => template.views.tagged_with }
    end
  end

protected

  def page_renderer(template, objects = {})
    "#{template.name.camelize}Renderer::#{self.action_name.camelize}".constantize.new(self, objects)
  end

end
