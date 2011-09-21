class Admin::CustomAttributesController < ApplicationController
  include Porthos::Admin
  include Porthos::Sweeper
  before_filter :find_page

  def create
    @field = @page.fields.find(params[:field_id])
    @custom_attribute = @field.data_type.new(params[:custom_attribute].merge({
      :field_id => @field.id,
      :handle   => @field.handle,
      :context  => @page
    }))
    @page.custom_attributes << @custom_attribute
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

  def update
    @custom_attribute = @page.custom_attributes.find(params[:id])
    @custom_attribute.update_attributes(params[:custom_attribute])
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

  def destroy
    @custom_attribute = @page.custom_attributes.find(params[:id])
    @custom_attribute.destroy
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

protected

  def find_page
    @page = Page.find(params[:page_id])
  end

end
