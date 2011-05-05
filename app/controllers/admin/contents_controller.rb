class Admin::ContentsController < ApplicationController
  respond_to :html
  include Porthos::Admin
  before_filter :find_datum_and_page
  skip_after_filter :remember_uri

  def new
    @content = params[:type].constantize.new(params[:content])
    render :template => "admin/contents/#{@content.class.to_s.tableize}/new"
  end

  def create
    @content = params[:type].constantize.new(params[:content])
    @datum.contents << @content
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def edit
    @content = @datum.contents.find(params[:id])
    render :template => "admin/contents/#{@content.class.to_s.tableize}/edit"
  end

  def update
    @content = @datum.contents.find(params[:id])
    if @content.update_attributes(params[:content])
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def destroy
    @content = @datum.contents.find(params[:id])
    @datum.contents.delete_if { |c| c._id == @content.id }
    if @page.save
      flash[:notice] = t(:deleted, :scope => [:app, :admin_general])
    end
    respond_with @content, :location => admin_page_path(@page)
  end

  def sort
    if params[:content]
      params[:content].each_with_index do |id, i|
        @datum.contents.detect { |c| c.id.to_s == id }.tap do |content|
          content.position = i
        end
      end
      @page.save
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def toggle
    @content = @datum.contents.find(params[:id])
    @content.update_attributes(:active => !@content.active)
    respond_with(@content, :location => admin_page_path(@page))
  end

  def settings
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html { }
    end
  end

protected

  def find_datum_and_page
    @page = Page.find(params[:page_id])
    @datum = @page.data.find(params[:datum_id])
  end

end