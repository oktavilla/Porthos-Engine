class Admin::AssetsController < ApplicationController
  include Porthos::Admin

  before_filter :login_required
  before_filter :set_callback,
                :only => [:index, :search]
  before_filter :find_tags,
                :only => [:index, :new]
  skip_before_filter :clear_callback
  skip_before_filter :remember_uri,
                     :only => [:index, :show, :create, :search]

  protect_from_forgery :only => :create

  has_scope :is_hidden, :default => false
  has_scope :created_by
  has_scope :by_type
  has_scope :order_by, :default => 'created_at DESC'

  def index
    @tags = Tag.on('Asset').limit(30)
    @assets = unless @current_tags.any?
      apply_scopes(Asset).paginate({
        :page     => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      })
    else
      Asset.is_public.find_tagged_with({:tags => params[:tags], :order => 'created_at DESC'})
    end
    respond_to do |format|
      format.html
    end
  end

  def search
    @type = params[:type] ? params[:type] : 'Asset'
    @tags = Tag.on('Asset').limit(30)
    unless params[:query].blank?
      query = params[:query]
      page = params[:page] || 1
      per_page = params[:per_page] ? params[:per_page].to_i : 44
      @search = Asset.search do
        keywords(query)
        with(:is_private, false)
        paginate :page => page, :per_page => per_page
      end
      @query = query
      @page = page
      respond_to do |format|
        format.html do
          @current_tags = params[:tags] || []
          @related_tags = @current_tags.any? ? @type.find_related_tags(@current_tags) : []
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_assets_path }
      end
    end
  end

  def show
    @asset = Asset.find(params[:id])
    respond_to do |format|
      format.html { redirect_to edit_admin_asset_path(@asset) }
      format.js { render :json => @asset.to_json(:methods => [:type, :thumbnail]) }
    end
  end

  def new
    @tags = []
    @asset = Asset.new
    respond_to do |format|
      format.html
    end
  end

  def edit
    @asset = Asset.find_by_name(params[:id]) || Asset.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def create
    if params[:asset]
      @assets = [Asset.from_upload(params[:asset].merge({:created_by => current_user}))]
    else
      @assets = params[:files].collect do |upload|
        Asset.from_upload(:file => upload, :created_by => current_user) unless upload.blank?
      end.compact
    end
    @not_saved = @assets.collect{ |a| a.save }.include? false
    respond_to do |format|
      unless @not_saved
        flash[:notice] = t(:saved, :scope => [:app, :admin_assets])
        format.html { redirect_to incomplete_admin_assets_url(:assets => @assets.collect {|asset| asset.id }) }
        format.json do
          render :text => @assets.collect{ |asset| asset.attributes_for_js }.to_json, :layout => false, :status => 200
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  def incomplete
    @assets = Asset.find(params[:assets])
  end

  def update_multiple
    params[:assets].each do |asset|
      save_asset = Asset.find(asset[0])
      save_asset.update_attributes(asset[1])
    end
    flash[:notice] = t(:saved, :scope => [:app, :admin_assets])
    respond_to do |format|
      format.html { redirect_to admin_assets_url }
    end
  end

  def update
    @asset = Asset.find_by_name(params[:id])
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        flash[:notice] = "#{@asset.full_name} #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to (params[:return_to] || edit_admin_asset_url(@asset)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @asset = Asset.find_by_name(params[:id]) || Asset.find(params[:id])
    @asset.destroy
    flash[:notice] = "#{@asset.full_name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_assets_path }
    end
  end

protected

  def find_tags
    @tags = Tag.on('Asset')
    @current_tags = params[:tags] || []
    @related_tags = @current_tags.any? ? Asset.find_related_tags(@current_tags) : []
  end

  def set_callback
    @create_callback = if params[:create_callback]
      session[:create_callback] = params[:create_callback]
    elsif session[:create_callback]
      session[:create_callback]
    end
  end

end
