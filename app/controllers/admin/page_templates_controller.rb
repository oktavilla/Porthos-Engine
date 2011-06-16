class Admin::PageTemplatesController < ApplicationController
  respond_to :html
  include Porthos::Admin

  def index
    @page_templates = PageTemplate.sort(:position).all
    respond_with(@page_templates)
  end

  def show
    @page_template = PageTemplate.find(params[:id])
    respond_with(@page_template)
  end

  def new
    @page_template = PageTemplate.new
  end

  def create
    @page_template = PageTemplate.new(params[:page_template])
    if @page_template.save
      flash[:notice] = "#{@page_template.label}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with(@page_template, :location => admin_page_template_path(@page_template))
  end

  def edit
    @page_template = PageTemplate.find(params[:id])
  end

  def update
    @page_template = PageTemplate.find(params[:id])
    if @page_template.update_attributes(params[:page_template])
      flash[:notice] = "#{@page_template.label}  #{t(:updated, :scope => [:app, :admin_general])}"
    end
    respond_with(@page_template, :location => params[:return_to] || admin_page_template_path(@page_template))
  end

  def destroy
    @page_template = PageTemplate.find(params[:id])
    if @page_template.destroy
      flash[:notice] = "#{@page_template.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    redirect_to admin_page_templates_path
  end

  def sort
    params[:page_template].each_with_index do |id, i|
      PageTemplate.update(id, :position => i+1)
    end if params[:page_template]
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

end