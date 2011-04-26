class Admin::ContentListsController < ApplicationController
  include Porthos::Admin
  
  
  def index
    @content_lists = ContentList.find(:all, :order => 'name')
    respond_to do |format|
      format.html
    end
  end

  def show
    @content_list = ContentList.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @content_list = ContentList.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @content_list = ContentList.new(params[:content_list])
    respond_to do |format|
      if @content_list.save
        format.html { redirect_to admin_content_lists_path }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @content_list = ContentList.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @content_list = ContentList.find(params[:id])
    respond_to do |format|
      if @content_list.update_attributes(params[:content_list])
        format.html { redirect_to admin_content_lists_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @content_list = ContentList.find(params[:id])
    @content_list.destroy
    respond_to do |format|
      format.html { redirect_to admin_content_lists_path }
    end
  end
  
end
