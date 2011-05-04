class Admin::ContentsController < ApplicationController
  respond_to :html
  include Porthos::Admin
  before_filter :find_content_block_and_page
  skip_after_filter :remember_uri

  def new
    @content = params[:type].constantize.new(params[:content])
    render :template => "admin/contents/#{@content.class.to_s.tableize}/new"
  end

  def create
    @content = params[:type].constantize.new(params[:content])
    @content_block.contents << @content
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def edit
    @content = @content_block.contents.find(params[:id])
    render :template => "admin/contents/#{@content.class.to_s.tableize}/edit"
  end

  def update
    @content = @content_block.contents.find(params[:id])
    if @content.update_attributes(params[:content])
      flash[:notice] = t(:saved, :scope => [:app, :admin_contents])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def destroy
    @content = @content_block.contents.find(params[:id])
    @content_block.contents.delete_if { |c| c._id == @content.id }
    if @page.save
      flash[:notice] = t(:deleted, :scope => [:app, :admin_general])
    end
    respond_with @content, :location => admin_page_path(@page)
  end

  def sort
    if params[:content]
      params[:content].each_with_index do |id, i|
        @content_block.contents.detect { |c| c.id.to_s == id }.tap do |content|
          content.position = i
        end
      end
      @page.save
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  Page.first(:conditions => { 'data' => { }})

  def toggle
    @content = @content_block.contents.find(params[:id])
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

  def find_content_block_and_page
    @page = Page.where('data.handle' => params[:content_block]).first
    @content_block = @page.data.detect { |d| d.handle == params[:content_block] }
  end

end