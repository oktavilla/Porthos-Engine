class Admin::FieldsController < ApplicationController
  include Porthos::Admin
  before_filter :find_field_set

  def new
    @field = @field_set.fields.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @field = params[:field_type].constantize.new(params[:field].merge(:field_set_id => @field_set.id))
    raise @field.valid?.inspect
    respond_to do |format|
      if @field.save
        flash[:notice] = "#{@field.label}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_field_set_path(@field_set) }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @field = @field_set.fields.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @field = @field_set.fields.find(params[:id])
    respond_to do |format|
      if @field.update_attributes(params[:field])
        flash[:notice] = "#{@field.label}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_field_set_path(@field_set) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @field = @field_set.fields.find(params[:id])
    if @field.destroy
      flash[:notice] = "#{@field.label}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_to do |format|
      format.html { redirect_to admin_field_set_path(@field_set) }
    end
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
