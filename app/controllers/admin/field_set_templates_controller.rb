class Admin::FieldSetTemplatesController < ApplicationController
  respond_to :html
  include Porthos::Admin

  def index
    @field_set_templates = FieldSetTemplate.all
    respond_with(@field_set_templates)
  end

  def show
    @field_set_template = FieldSetTemplate.find(params[:id])
    respond_with(@field_set_template)
  end

  def new
    @field_set_template = FieldSetTemplate.new
  end

  def create
    @field_set_template = FieldSetTemplate.new(params[:field_set_template])
    if @field_set_template.save
      flash[:notice] = "#{@field_set_template.title}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with(@field_set_template, :location => admin_field_set_template_path(@field_set_template))
  end

  def edit
    @field_set_template = FieldSetTemplate.find(params[:id])
  end

  def update
    @field_set_template = FieldSetTemplate.find(params[:id])
    if @field_set_template.update_attributes(params[:field_set_template])
      flash[:notice] = "#{@field_set_template.title}  #{t(:updated, :scope => [:app, :admin_general])}"
    end
    respond_with(@field_set_template, :location => admin_field_set_template_path(@field_set_template))
  end

  def destroy
    @field_set_template = FieldSetTemplate.find(params[:id])
    if @field_set_template.destroy
      flash[:notice] = "#{@field_set_template.title}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    redirect_to admin_field_set_templates_path
  end
end