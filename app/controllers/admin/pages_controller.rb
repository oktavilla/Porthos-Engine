class Admin::PagesController < ApplicationController
  include Porthos::Admin
  before_filter :login_required

  has_scope :with_field_set
  has_scope :created_by
  has_scope :updated_by
  has_scope :order_by, :default => 'updated_at desc'
  has_scope :is_published, :type => :boolean

  def index
    @field_sets = FieldSet.ordered
    @field_set = FieldSet.find(params[:with_field_set]) if params[:with_field_set].present?

    @tags = Tag.on('Page')
    @current_tags = params[:tags] || []
    @related_tags = @current_tags.any? ? Page.find_related_tags(@current_tags) : []

    @pages = unless @current_tags.any?
      apply_scopes(Page).paginate({
        :page     => (params[:page] || 1),
        :per_page => (params[:per_page] || 25)
      })
    else
      Page.tagged_with(params[:tags])
    end
    respond_to do |format|
      format.html
    end
  end

  def search
    query = params[:query]
    page  = params[:page] || 1
    per_page = params[:per_page] ? params[:per_page].to_i : 45
    @search = Page.search do
      keywords(query)
      paginate :page => page, :per_page => per_page
    end
    @query = query
    @page = page
    @field_sets = FieldSet.ordered
    respond_to do |format|
      format.html
    end
  end

  def show
    @page = Page.find(params[:id])
    if @page.node and @page.node.parent
      cookies[:last_opened_node] = { :value => @page.node.parent.id.to_s, :expires => 1.week.from_now }
    end
    respond_to do |format|
      format.html
    end
  end

  def comments
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @page = Page.new(params[:page])
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @page = Page.new(params[:page])
    respond_to do |format|
      if @page.save
        format.html { redirect_to admin_page_path(@page.id) }
      else
        format.html { render :action => :new }
      end
    end
  end

  def update
    @page = Page.find(params[:id])
    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
        if @page.can_have_a_node?
          format.html { redirect_to new_admin_node_path(:resource_id => @page.id) }
        else
          format.html { redirect_to params[:return_to] || admin_page_path(@page.id) }
        end
      else
        format.html { render :action => 'show' }
      end
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    respond_to do |format|
      flash[:notice] = "#{@page.title} #{t(:deleted, :scope => [:app, :admin_general])}"
      format.html { redirect_to admin_pages_path }
    end
  end

  def publish
    @page = Page.find(params[:id])
    @page.update_attributes(:published_on => Time.now)
    respond_to do |format|
      format.html do
        if @page.can_have_a_node?
          redirect_to new_admin_node_path(:resource_id => @page.id)
        else
          redirect_back_or_default(admin_page_path(@page.id))
        end
      end
    end
  end

  def sort
    params[:page].each_with_index do |id, i|
      Page.update(id, :first => (i == 0), :next_id => params[:page][i+1])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
