class Admin::ItemsController < ApplicationController
  include Porthos::Admin
  respond_to :html, :json

  has_scope :with_page_template
  has_scope :order_by
  has_scope :created_by
  has_scope :updated_by
  has_scope :is_published

  def index
    respond_to do |format|
      format.html do
        @page_templates = PageTemplate.sort(:position).all
        @page_template = PageTemplate.find(params[:with_page_template]) if params[:with_page_template]
        order = @page_template && @page_template.sortable? ? @page_template.sortable : :updated_on.desc
        @tags = Page.tags_by_count
        if @page_template
          @categories = Page.tags_by_count(namespace: @page_template.handle)
        end
        @current_tags = params[:tags] || []
        @items = unless @current_tags.any?
          klass = params[:type] ? params[:type].constantize : Page
          scoped = apply_scopes(klass)
          unless current_scopes.include?(:order_by)
            scoped = scoped.sort(order)
          end
          scoped.page(params[:page])
        else
          tagging_options = (@page_template ? { :namespace => @page_template.handle } : {}).merge(params[:taggings] || {}).to_options
          Page.tagged_with(@current_tags, tagging_options).sort(:updated_at.desc).page(params[:page])
        end
      end

      format.json do
        render json: Item.published.fields(:id, :_type, :title, :page_template_id).sort(:title).all.to_json
      end
    end
  end

  def search
    @query = params[:query]
    per_page = params[:per_page] ? params[:per_page].to_i : 45
    @pages = Page.search_tank(@query, :per_page => per_page, :page => params[:page])
    @page_templates = PageTemplate.all
    respond_with(@pages)
  end

  def show
    @item = Item.find(params[:id])
    respond_to do |format|
      format.html { render template: (@item.class == Page ? 'admin/items/page' : 'admin/items/section') }
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

  def toggle
    @item = Item.find(params[:id])
    @item.update_attributes(:published_on => (@item.published? ? nil : Time.now))
    respond_to do |format|
      format.html do
        if @item.published? && @item.can_have_a_node? && !@item.node
          redirect_to new_admin_node_path(:resource_id => @item.id)
        else
          redirect_to admin_item_path(@item.id)
        end
      end
    end
  end

  def sort
    params[:item].each_with_index do |id, index|
      object_id = BSON::ObjectId.from_string id
      Page.set(object_id, :position => index+1)
    end

    if params[:page_template_id]
      object_id = BSON::ObjectId.from_string params[:page_template_id]
      PageTemplate.set object_id, updated_at: Time.zone.now.utc
    end

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
