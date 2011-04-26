class Admin::FieldsController < ApplicationController
  include Porthos::Admin
  respond_to :html
  before_filter :find_field_set

  def new
    @field = params[:field_type].constantize.new
  end

  def create
    @field = params[:field_type].constantize.new(params[:field])
    @field_set.fields << @field
    if @field.save
      flash[:notice] = "#{@field.label}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @field, :location => admin_field_set_path(@field_set)
  end

  def edit
    @field = @field_set.fields.find(params[:id])
  end

  def update
    @field = @field_set.fields.find(params[:id])
    if @field.update_attributes(params[:field])
      flash[:notice] = "#{@field.label} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @field, :location => admin_field_set_path(@field_set)
  end

  def destroy
    @field = @field_set.fields.find(params[:id])
    if @field_set.pull(:fields => { :_id => @field.id })
      flash[:notice] = "#{@field.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_with @field, :location => admin_field_set_path(@field_set)
  end

  def sort
    params[:field].each_with_index do |id, i|
      Field.update_all({:first => (i == 0), :next_id => params[:field][i+1]}, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected

  def find_field_set
    @field_set = FieldSet.find(params[:field_set_id])
  end

end