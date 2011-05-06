class Admin::DataController < ApplicationController
  respond_to :html
  include Porthos::Admin
  before_filter :find_page
  skip_after_filter :remember_uri

  def update
    @datum = @page.data.find(params[:id])
    if @datum.update_attributes(params[:datum])
      flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
    end
    respond_with(@datum, :location => admin_page_path(@page))
  end

protected

  def find_page
    @page = Page.find(params[:page_id])
  end

end