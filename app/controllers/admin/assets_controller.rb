class Admin::AssetsController < ApplicationController
  respond_to :html
  include Porthos::Admin
  before_filter :set_callback,
                :only => [:index, :search]
  before_filter :find_tags,
                :only => [:index, :new]
  skip_before_filter :clear_callback

  protect_from_forgery :only => :create

  has_scope :is_hidden, :default => false
  has_scope :created_by
  has_scope :by_type
  has_scope :by_filetype, :type => :array
  has_scope :order_by, :default => 'created_at DESC'

  def index
    @tags = Asset.tags_by_count(:limit => 30)
    @assets = unless @current_tags.any?
      apply_scopes(Asset).page(params[:page])
    else
      Asset.tagged_with(params[:tags]).where(:hidden => false).sort(:created_at.desc)
    end
    respond_with(@assets)
  end

  def search
    @type = params[:type] ? params[:type] : 'Asset'
    @tags = Asset.tags_by_count(:limit => 30)
    unless params[:query].blank?
      @query = params[:query]
      page = params[:page] || 1
      per_page = params[:per_page] ? params[:per_page].to_i : 45
      @assets = Asset.search_tank(@query, :conditions => {'hidden' => false}, :per_page => per_page, :page => page)
      respond_to do |format|
        format.html do
          @current_tags = params[:tags] || []
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_assets_path }
      end
    end
  end

  def new
    @asset = Asset.new
  end

  def edit
    @asset = Asset.find(params[:id])
  end

  def create
    @assets = if params[:asset][:file].is_a?(Array)
      params[:asset][:file].collect do |file|
        Asset.from_upload(:file => file, :created_by => current_user)
      end
    else
      [Asset.from_upload(params[:asset].merge({:created_by => current_user}))]
    end
    @not_saved = @assets.collect { |a| a.save }.include? false
    respond_to do |format|
      unless @not_saved
        flash[:notice] = t(:saved, :scope => [:app, :admin_assets])
        format.html { redirect_to incomplete_admin_assets_url(:assets => @assets.collect {|asset| asset.id }) }
        format.json do
          render :text => @assets.to_json, :layout => false, :status => 200
        end
      else
        @asset = @assets.first
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
    @asset = Asset.find(params[:id])
    if @asset.update_attributes(params[:asset])
      flash[:notice] = "#{@asset.full_name} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @asset, :location => (params[:return_to] || edit_admin_asset_url(@asset))
  end

  def destroy
    @asset = Asset.find_by_name(params[:id]) || Asset.find(params[:id])
    @asset.destroy
    flash[:notice] = "#{@asset.full_name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_with @asset, :location => (params[:return_to] || admin_assets_path)
  end

  def edit_cropping
    @asset = Asset.find_by_name(params[:id]) || Asset.find(params[:id])
    @cropping = (@asset.versions[params[:cropping]] || {}).tap do |_cropping|
      _cropping[:width], _cropping[:height] = params[:cropping].gsub('c','').split('x')
    end
    respond_to do |format|
      format.html
    end
  end

protected

  def find_tags
    @tags = Asset.tags_by_count(:limit => 30)
    @current_tags = params[:tags] || []
  end

  def set_callback
    @create_callback = if params[:create_callback]
      session[:create_callback] = params[:create_callback]
    elsif session[:create_callback]
      session[:create_callback]
    end
  end

end