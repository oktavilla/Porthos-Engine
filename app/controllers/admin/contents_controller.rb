class Admin::ContentsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  skip_after_filter :remember_uri

  def show
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render :json => @content.to_json }
    end
  end

  def new
    @content = Content.new(params[:content])
    @content.resource = @content.resource_class.new(params[:resource])
    respond_to do |format|
      format.html { render :template => @content.resource.view_path(:new) }
      format.js   { render :template => @content.resource.view_path(:new), :layout => false }
    end
  end

  def edit
    @content  = Content.find(params[:id])
    @resource = @content.resource

    if params[:resource]
      @asset = Asset.find(params[:resource][:image_asset_id] || params[:resource][:video_asset_id])
    end

    respond_to do |format|
      format.html { render :template => @content.resource.view_path(:edit) }
      format.js   { render :template => @content.resource.view_path(:edit), :layout => false }
    end
  end

  def update
    @content = Content.find(params[:id])
    @content.resource.update_attributes(params[:resource]) if params[:resource]
    @content.update_attributes(params[:content]) if params[:content]
    @saved = @content.valid? && @content.resource.valid?
    respond_to do |format|
      if @saved
        format.html { redirect_to restfull_path_for(@content.context, :anchor => "content_#{@content.id}") }
      else
        format.html { render :template => @content.resource.view_path(:edit) }
      end
    end
  end

  def create
    Content.transaction do
      @content = Content.new({
        :column_position => 1,
        :active => 1
      }.stringify_keys.merge(params[:content]))
      if @content.resource_id.blank?
        @resource = @content.resource_class.new(params[:resource])
        @resource.parent = @content if @resource.respond_to?(:parent)
        @resource.save!
        @content.resource = @resource
      end
      @content.save!
      if params[:collection] && params[:collection].to_i == 1
        @collection = ContentCollection.create(params[:content])
        @collection.contents << @content
      end
    end
    respond_to do |format|
      format.html { redirect_to restfull_path_for(@content.context, :anchor => "content_#{@content.id}") }
    end
  rescue ActiveRecord::RecordInvalid
    @content.valid?
    respond_to do |format|
      format.html { render :template => (@resource || @content.resource).send(:view_path, :new) }
      format.js { render :template => (@resource || @content.resource).send(:view_path, :new), :layout => false }
    end
  end

  def destroy
    @content = Content.find(params[:id])
    @content.destroy
    flash[:notice] = t(:saved, :scope => [:app, :admin_contents]) unless @content.resource and @content.resource_type == 'ContentTextfield' and @content.resource.body.blank?
    respond_to do |format|
      format.html { redirect_to restfull_path_for(@content.context) }
    end
  end

  def sort
    if params[:content]
      timestamp = Time.now
      params[:content].each_with_index do |id, i|
        attributes = {}
        attributes[:column_position] = params[:column_position] if params[:column_position]
        attributes[:parent_id] = params[:parent_id] if params[:parent_id]
        Content.update_all({
          :first => (i == 0),
          :next_id => params[:content][i+1],
          :updated_at => timestamp
        }.merge(attributes), ["id = ?", id])
      end
      Content.find_by_id(params[:content].last).tap do |content|
        content.context.touch if content && content.context
      end
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def toggle
    @content = Content.find(params[:id])
    @content.update_attributes(:active => !@content.active)
    respond_to do |format|
      format.html { redirect_to restfull_path_for(@content.context, :anchor => "content_#{@content.id}") }
      format.js
    end
  end

  def settings
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html { }
    end
  end
end
