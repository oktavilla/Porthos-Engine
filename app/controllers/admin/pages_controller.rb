class Admin::PagesController < ApplicationController
  include Porthos::Admin
  respond_to :html

  has_scope :with_field_set
  has_scope :created_by
  has_scope :updated_by
  has_scope :order_by, :default => 'updated_at desc'
  has_scope :is_published, :type => :boolean

  def index
    @field_sets = FieldSet.all
    @field_set = FieldSet.find(params[:with_field_set]) if params[:with_field_set].present?

    @tags = Page.tags_by_count(:limit => 30)
    @current_tags = params[:tags] || []

    @pages = unless @current_tags.any?
      apply_scopes(Page).paginate({
        :page     => (params[:page] || 1),
        :per_page => (params[:per_page] || 25)
      })
    else
      Page.tagged_with(@current_tags).sort(:updated_at.desc)
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
    @field_sets = FieldSet.all
    respond_to do |format|
      format.html
    end
  end

  def show
    @page = Page.find(params[:id])
    # if @page.node and @page.node.parent
    #   cookies[:last_opened_node] = { :value => @page.node.parent.id.to_s, :expires => 1.week.from_now }
    # end
    respond_to do |format|
      format.html
    end
  end

  def new
    @page = Page.new(params[:page])
  end

  def create
    @page = Page.new(params[:page])
    @page.clone_field_set
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
    end
    respond_with(@page, :location => admin_page_path(@page.id))
  end

  def update
    @page = Page.find(params[:id])
    respond_to do |format|
      if @page.update_attributes(params[:page])
        @page.reload
        flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
        format.html { redirect_to params[:return_to] || admin_page_path(@page.id) }
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
          redirect_to admin_page_path(@page.id)
        end
      end
    end
  end

  def sort
    timestamp = Time.now
    params[:page].each_with_index do |id, i|
      Page.update_all({
        :first => (i == 0),
        :next_id => params[:page][i+1],
        :position => i+1,
        :updated_at => timestamp
      }, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
