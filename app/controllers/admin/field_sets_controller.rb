class Admin::FieldSetsController < ApplicationController
  respond_to :html
  include Porthos::Admin


  def index
    @field_sets = FieldSet.all
    respond_with(@field_sets)
  end

  def show
    @field_set = FieldSet.find(params[:id])
    respond_with(@field_set)
  end

  def new
    @field_set = FieldSet.new
  end

  def create
    @field_set = FieldSet.new(params[:field_set])
    if @field_set.save
      flash[:notice] = "#{@field_set.title}  #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with(@field_set, :location => admin_field_set_path(@field_set))
  end

  def edit
    @field_set = FieldSet.find(params[:id])
  end

  def update
    @field_set = FieldSet.find(params[:id])
    if @field_set.update_attributes(params[:field_set])
      flash[:notice] = "#{@field_set.title}  #{t(:updated, :scope => [:app, :admin_general])}"
    end
    respond_with(@field_set, :location => admin_field_set_path(@field_set))
  end

  def destroy
    @field_set = FieldSet.find(params[:id])
    if @field_set.destroy
      flash[:notice] = "#{@field_set.title}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    redirect_to admin_field_sets_path
  end

  def sort
    timestamp = Time.now
    params[:field_set].each_with_index do |id, i|
      FieldSet.update_all({
        :first => (i == 0),
        :next_id => params[:field_set][i+1],
        :updated_at => timestamp
      }, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def pages
    @field_set = FieldSet.find(params[:id])
    @pages = @field_set.pages.all
    respond_to do |format|
      format.html
    end
  end
end
