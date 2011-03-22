class Admin::SiteSettingsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def index
    @site_settings = SiteSetting.find(:all)
    respond_to do |format|
      format.html {}
    end
  end
  
  def new
    @site_setting = SiteSetting.new
    respond_to do |format|
      format.html {}
    end
  end
  
  def create
    @site_setting = SiteSetting.new(params[:site_setting])
    respond_to do |format|
      if @site_setting.save
        flash[:notice] = t(:saved, :scope => [:app, :admin_general])
        format.html { redirect_to admin_site_settings_path }
      else
        format.html { render :action => :new }
      end
    end
  end
  
  def edit
    @site_setting = SiteSetting.find(params[:id])
    respond_to do |format|
      format.html {}
    end
  end
  
  def update
    @site_setting = SiteSetting.find(params[:id])
    respond_to do |format|
      if @site_setting.update_attributes(params[:site_setting])
        flash[:notice] = t(:saved, :scope => [:app, :admin_general])
        format.html { redirect_to admin_site_settings_path }
      else
        format.html { render :action => :edit }
      end
    end
  end
  
  def destroy
    @site_setting = SiteSetting.find(params[:id])
    @site_setting.destroy
    respond_to do |format|
      flash[:notice] = t(:deleted, :scope => [:app, :admin_general])
      format.html { redirect_to admin_site_settings_path }
    end
  end
end