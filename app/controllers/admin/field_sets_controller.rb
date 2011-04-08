class Admin::FieldSetsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required

  def index
    @field_sets = FieldSet.ordered
    respond_to do |format|
      format.html
    end
  end

  def show
    @field_set = FieldSet.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @field_set = FieldSet.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @field_set = FieldSet.new(params[:field_set])
    respond_to do |format|
      if @field_set.save
        flash[:notice] = "#{@field_set.title}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_field_set_path(@field_set) }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @field_set = FieldSet.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @field_set = FieldSet.find(params[:id])
    respond_to do |format|
      if @field_set.update_attributes(params[:field_set])
        flash[:notice] = "#{@field_set.title}  #{t(:updated, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_field_set_path(@field_set) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @field_set = FieldSet.find(params[:id])
    if @field_set.destroy
      flash[:notice] = "#{@field_set.title}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_to do |format|
      format.html { redirect_to admin_field_sets_path }
    end
  end

  def sort
    params[:field_set].each_with_index do |id, i|
      FieldSet.update_all({:first => (i == 0), :next_id => params[:field_set][i+1]}, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def pages
    @field_set = FieldSet.find(params[:id])
    @pages = @field_set.pages.ordered
    respond_to do |format|
      format.html
    end
  end
end
