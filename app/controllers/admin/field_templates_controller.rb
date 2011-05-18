class Admin::DatumTemplatesController < ApplicationController
  include Porthos::Admin
  respond_to :html
  before_filter :find_page_template

  def new
    @datum_template = params[:template_type].constantize.new
  end

  def create
    @datum_template = params[:template_type].constantize.new(params[:field])
    @page_template.fields << @datum_template
    if @datum_template.save
      flash[:notice] = "#{@datum_template.label}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => admin_page_template_path(@page_template)
  end

  def edit
    @datum_template = @page_template.fields.find(params[:id])
  end

  def update
    @datum_template = @page_template.fields.find(params[:id])
    if @datum_template.update_attributes(params[:field])
      flash[:notice] = "#{@datum_template.label} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => admin_page_template_path(@page_template)
  end

  def destroy
    @datum_template = @page_template.fields.find(params[:id])
    if @page_template.pull(:fields => { :_id => @datum_template.id })
      flash[:notice] = "#{@datum_template.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_with @datum_template, :location => admin_page_template_path(@page_template)
  end

  def sort
    params[:datum_template].each_with_index do |id, i|
      Field.update_all({:first => (i == 0), :next_id => params[:field][i+1]}, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected

  def find_page_template
    @page_template = PageTemplate.find(params[:page_template_id])
  end

end