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
    raise @content_block.inspect
    @page.contents << @content
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def show
    @content = @page.contents.find(params[:id])
    respond_with(@content)
  end

  def edit
    @content = @page.contents.find(params[:id])
  end

  def update
    @content = @page.contents.find(params[:id])
    if @content.update_attributes(params[:content])
      flash[:notice] = t(:saved, :scope => [:app, :admin_contents])
    end
    respond_with(@content, :location => admin_page_path(@page))
  end

  def destroy
    @content = @field_set.data.find(params[:id])
    if @field_set.pull(:fields => { :_id => @field.id })
      flash[:notice] = "#{@field.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_with @field, :location => admin_field_set_path(@field_set)
  end

  def sort
    timestamp = Time.now
    params[:content].each_with_index do |id, i|
      attributes = {}
      attributes[:column_position] = params[:column_position] if params[:column_position]
      attributes[:parent_id] = params[:parent_id] if params[:parent_id]
      Content.update_all({
        :first => (i == 0),
        :next_id => params[:content][i+1],
        :updated_at => timestamp
      }.merge(attributes), ["id = ?", id])
    end if params[:content]
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  Page.first(:conditions => { 'data' => { }})

  def toggle
    @content = Content.find(params[:id])
    @content.update_attributes(:active => !@content.active)
    respond_to do |format|
      format.html { redirect_to restfull_path_for(@content.context, :anchor => "content_#{@content.id}") }
      format.js
    end
  end

  def settings
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html { }
    end
  end

protected

  def find_content_block_and_page
    raise Page.where(:data => { :id => params[:content_block_id] }).first.inspect
    @page = Page.find(:data => { :id => params[:content_block_id]}).first
    @content_block = @page.data.detect { |d| d.id.to_s = params[:content_block_id] }
  end

end
