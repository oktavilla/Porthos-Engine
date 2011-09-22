class Admin::RedirectsController < ApplicationController
  include Porthos::Admin
  respond_to :html

  def index
    @redirects = Redirect.all(order: 'path')
  end

  def new
    @redirect = Redirect.new
  end

  def create
    @redirect = Redirect.new(params[:redirect])
    flash[:notice] = t(:saved, scope: [:app, :admin_redirects]) if @redirect.save
    respond_with(@redirect, location: admin_redirects_path)
  end

  def edit
    @redirect = Redirect.find(params[:id])
  end

  def update
    @redirect = Redirect.find(params[:id])
    flash[:notice] = t(:saved, scope: [:app, :admin_redirects]) if @redirect.update_attributes(params[:redirect])
    respond_with(@redirect, location: admin_redirects_path)
  end

  def destroy
    @redirect = Redirect.find(params[:id])
    @redirect.destroy
    flash[:notice] = t(:deleted, scope: [:app, :admin_redirects])
    redirect_to admin_redirects_path
  end
end
