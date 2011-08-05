class Admin::ItemsController < ApplicationController
  include Porthos::Admin
  respond_to :html

  has_scope :with_page_template
  has_scope :created_by
  has_scope :updated_by
  has_scope :order_by,
            :default => 'updated_at desc'
  has_scope :is_published

  def index
    @page_templates = PageTemplate.sort(:position).all
    @page_template = PageTemplate.find(params[:with_page_template]) if params[:with_page_template]

    @tags = Page.tags_by_count(:limit => 30)
    @current_tags = params[:tags] || []
    @items = unless @current_tags.any?
      klass = params[:type] ? params[:type].constantize : Page
      apply_scopes(klass).page(params[:page])
    else
      Page.tagged_with(@current_tags).sort(:updated_at.desc).page(params[:page])
    end
    respond_with(@items)
  end

  def search
    @query = params[:query]
    page = params[:page] || 1
    per_page = params[:per_page] ? params[:per_page].to_i : 45
    @pages = Page.search_tank(@query, :per_page => per_page, :page => page)
    @page_templates = PageTemplate.all
    respond_with(@pages)
  end

  def show
    @item = Item.find(params[:id])
    respond_to do |format|
      format.html { render template: (@item.is_a?(Page) ? 'admin/items/page' : 'admin/items/section') }
    end
  end

  def new
    @template = Template.find(params[:page_template_id])
    klass = (params[:type] ? params[:type].constantize : Page)
    @item = if @template
      klass.from_template(@template, params[:item] || {})
    else
      klass.new(params[:item])
    end
  end

  def create
    @template = Template.find(params[:page_template_id])
    @item = (params[:type] ? params[:type].constantize : Page).from_template(@template, params[:item] || {})
    if @item.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_items])
    end
    respond_with(@item, :location => admin_item_path(@item.id))
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      flash[:notice] = t(:saved, :scope => [:app, :admin_items])
    end
    respond_with @item, :location => (params[:return_to] || admin_item_path(@item.id))
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    flash[:notice] = "#{@item.title} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_with @item, :location => admin_items_path(:with_page_template => @item.page_template_id)
  end

  def publish
    @item = Item.find(params[:id])
    @item.update_attributes(:published_on => Time.now)
    respond_to do |format|
      format.html do
        if @item.can_have_a_node?
          redirect_to new_admin_node_path(:resource_id => @item.id)
        else
          redirect_to admin_item_path(@item.id)
        end
      end
    end
  end

  def sort
    timestamp = Time.now
    params[:item].each_with_index do |id, i|
      Page.set(id, :position => i+1)
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end