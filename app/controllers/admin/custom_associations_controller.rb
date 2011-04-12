class Admin::CustomAssociationsController < ApplicationController
  include Porthos::Admin
  before_filter :find_page, :except => :sort

  def create
    @page.custom_associations.create(params[:custom_association])
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

  def update
    @custom_association = @page.custom_associations.find(params[:id])
    @custom_association.update_attributes(params[:custom_association])
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

  def destroy
    @custom_association = @page.custom_associations.find(params[:id])
    @custom_association.destroy
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page.id) }
    end
  end

  def sort
    timestamp = Time.now
    params[:custom_association].each_with_index do |id, i|
      CustomAssociation.update_all({
        :first => (i == 0),
        :next_id => params[:custom_association][i+1],
        :updated_at => timestamp
      }, ["id = ?", id])
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected

  def find_page
    @page = Page.find(params[:page_id])
  end

end