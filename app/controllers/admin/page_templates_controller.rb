class Admin::PageTemplatesController < ApplicationController
  respond_to :html
  include Porthos::Admin

  def index
    @page_templates = PageTemplate.all
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
      flash[:notice] = "#{@page_template.title}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with(@page_template, :location => admin_page_template_path(@page_template))
  end

  def edit
    @page_template = PageTemplate.find(params[:id])
  end

  def update
    @page_template = PageTemplate.find(params[:id])
    if @page_template.update_attributes(params[:page_template])
      flash[:notice] = "#{@page_template.title}  #{t(:updated, :scope => [:app, :admin_general])}"
    end
    respond_with(@page_template, :location => admin_page_template_path(@page_template))
  end

  def destroy
    @page_template = PageTemplate.find(params[:id])
    if @page_template.destroy
      flash[:notice] = "#{@page_template.title}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    redirect_to admin_page_templates_path
  end
end