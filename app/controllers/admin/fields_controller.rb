class Admin::FieldsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required,
                :find_field_set
  
  def new
    @field = @field_set.fields.build
    respond_to do |format|
      format.html
    end
  end

  def create
    if Field.types.include?(params[:field_type].constantize)
      @field = params[:field_type].constantize.new(params[:field].merge(:field_set_id => @field_set.id))
    end
    respond_to do |format|
      if @field.save
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
        format.html { redirect_to admin_field_set_path(@field_set) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @field = @field_set.fields.find(params[:id])
    @field.destroy
    respond_to do |format|
      format.html { redirect_to admin_field_set_path(@field_set) }
    end
  end

  def sort
    params[:fields].each_with_index do |id, index|
      @field_set.fields.update(id, :position => index + 1)
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