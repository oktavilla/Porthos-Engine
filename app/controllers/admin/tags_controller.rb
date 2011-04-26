class Admin::TagsController < ApplicationController
  include Porthos::Admin
  

  skip_before_filter :clear_content_context, :only => [:search]

  def index
    @tags = Tag.find(:all, :order => 'name')
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    respond_to do |format|
      if @tag.save
        flash[:notice] = "#{@tag.name}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_tags_path }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    new_attributes = params[:tag]
    if @existing_tag = Tag.find_by_name(new_attributes[:name].strip)
      @tag.taggings.update_all(:tag_id => @existing_tag.id)
      @tag.destroy
      @tag = @existing_tag
    else
      @tag.update_attributes(params[:tag])
    end
    respond_to do |format|
      if @tag.valid?
        flash[:notice] = "#{@tag.name}  #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_tag_path(@tag) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    if @tag.destroy
      flash[:notice] = "#{@tag.name}  #{t(:deleted, :scope => [:app, :admin_general])}"
    end
    respond_to do |format|
      format.html { redirect_to admin_tags_path }
    end
  end

  def search
    @tags = Tag.where("name LIKE ?", "#{params[:query].downcase.strip}%")
    respond_to do |format|
      format.js
    end
  end
end
