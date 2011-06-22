class Admin::PagesController < ApplicationController
  include Porthos::Admin
  respond_to :html

  has_scope :with_page_template
  has_scope :created_by
  has_scope :updated_by
  has_scope :order_by, :default => 'position asc, updated_at desc'
  has_scope :is_published

  def index
    @page_templates = PageTemplate.sort(:position).all
    @page_template = PageTemplate.find(params[:with_page_template]) if params[:with_page_template]

    @tags = Page.tags_by_count(:limit => 30)
    @current_tags = params[:tags] || []
    @pages = unless @current_tags.any?
      apply_scopes(Page).page(params[:page])
    else
      Page.tagged_with(@current_tags).sort(:updated_at.desc).page(params[:page])
    end
    respond_with(@pages)
  end

  def search
    @query = params[:query]
    page  = params[:page] || 1
    per_page = params[:per_page] ? params[:per_page].to_i : 45
    @pages = Page.search_tank(@query, :per_page => per_page, :page => page)
    @page_templates = PageTemplate.all
    respond_with(@pages)
  end

  def show
    @page = Item.find(params[:id])
    respond_with(@page)
  end

  def new
    @template = Template.find(params[:page_template_id])
    @page = (params[:type] ? params[:type].constantize : Page).from_template(@template, params[:page] || {})
  end

  def create
    @template = Template.find(params[:page_template_id])
    @page = (params[:type] ? params[:type].constantize : Page).from_template(@template, params[:page] || {})
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
    end
    respond_with(@page, :location => admin_page_path(@page.id))
  end

  def update
    @page = Item.find(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
    end
    respond_with @page, :location => (params[:return_to] || admin_page_path(@page.id))
  end

  def destroy
    @page = Item.find(params[:id])
    @page.destroy
    flash[:notice] = "#{@page.title} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_with @page, :location => admin_pages_path(:with_page_template => @page.page_template_id)
  end

  def publish
    @page = Item.find(params[:id])
    @page.update_attributes(:published_on => Time.now)
    respond_to do |format|
      format.html do
        if @page.can_have_a_node?
          redirect_to new_admin_node_path(:resource_id => @page.id)
        else
          redirect_to admin_page_path(@page.id)
        end
      end
    end
  end

  def sort
    timestamp = Time.now
    params[:page].each_with_index do |id, i|
      Page.set(id, :position => i+1)
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
