class Admin::ContentModulesController < ApplicationController
  include Porthos::Admin
  
  
  def index
    @content_modules = ContentModule.find(:all, :order => "name")
    @content_module  = ContentModule.new
  end
  
  def new
    @content_module = ContentModule.new
  end
  
  def create
    @content_module = ContentModule.new(params[:content_module])
    respond_to do |format|
      if @content_module.save
        flash[:notice] = "#{@content_module.name}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_content_modules_path }
      else
        format.html { render :action => :new }
      end
    end
  end
  
  def edit
    @content_module = ContentModule.find(params[:id])
  end
  
  def update
    @content_module = ContentModule.find(params[:id])
    respond_to do |format|
      if @content_module.update_attributes(params[:content_module])
        flash[:notice] = "#{@content_module.name}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_content_modules_path }
      else
        format.html { render :action => :new }
      end
    end
  end
  
  def destroy
    @content_module = ContentModule.find(params[:id])
    @content_module.destroy
    flash[:notice] = "#{@content_module.name}  #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_content_modules_path }
    end
  end
  
end
