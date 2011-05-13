class Admin::DataController < ApplicationController
  respond_to :html
  include Porthos::Admin
  before_filter :find_page
  skip_after_filter :remember_uri

  def new
    @datum = params[:type].constantize.new(params[:datum])
    render :template => "admin/data/#{@datum.class.to_s.tableize}/new"
  end

  def create
    @datum = params[:type].constantize.new(params[:datum])
    @parent.data << @datum
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@datum, :location => admin_page_path(@page))
  end

  def edit
    @datum = @parent.data.find(params[:id])
    render :template => "admin/data/#{@datum.class.to_s.tableize}/edit"
  end

  def update
    @datum = @parent.data.find(params[:id])
    if @datum.update_attributes(params[:datum])
      flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
    end
    respond_with(@datum, :location => admin_page_path(@page))
  end

protected

  def find_page
    @page = Page.find(params[:page_id])
    if params[:parent_id]
      @parent = @page.data.find(params[:parent_id])
    else
      @parent = @page
    end
  end


end