class Admin::DataController < ApplicationController
  include Porthos::Admin
  respond_to :html, :json
  before_filter :find_page

  def new
    @datum = unless params[:template_id]
      params[:type].constantize.new(params[:datum])
    else
      @template = Template.find(params[:template_id])
      @template.to_datum(params[:datum])
    end
  end

  def create
    unless params[:template_id]
      @datum = params[:type].constantize.new(params[:datum])
    else
      @template = Template.find(params[:template_id])
      @datum = @template.to_datum(params[:datum])
    end
    @parent.data << @datum
    if @page.save
      flash[:notice] = t(:saved, :scope => [:app, :admin_general])
    end
    respond_with(@datum, :location => admin_page_path(@page, :anchor => "datum_#{@datum.id}_edit"))
  end

  def edit
    @datum = @parent.data.find(params[:id])
    render :template => "admin/data/#{@datum.class.to_s.tableize}/edit"
  end

  def update
    @datum = @parent.data.find(params[:id])
    respond_to do |format|
      if @datum.update_attributes(params[:datum])
        format.html do
          flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
          redirect_to admin_page_path(@page, :anchor => "datum_#{@datum.id}")
        end
        format.json { render :json => @datum.to_json, :status => :ok }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @datum.errors.to_json, :status => :not_acceptable }
      end
    end
  end

  def toggle
    @datum = @parent.data.find(params[:id])
    @datum.update_attributes(:active => !@datum.active)
    respond_with(@datum, :location => admin_page_path(@page, :anchor => "datum_#{@datum.id}"))
  end

  def destroy
    @datum = @parent.data.find(params[:id])
    @parent.data.delete_if { |d| d._id == @datum.id }
    if @page.save
      flash[:notice] = t(:deleted, :scope => [:app, :admin_general])
    end
    respond_with @datum, :location => admin_page_path(@page, :location => "datum_#{@datum.id}")
  end

  def sort
    if params[:datum]
      params[:datum].each_with_index do |id, i|
        @parent.data.detect { |c| c.id.to_s == id }.tap do |datum|
          datum.position = i+1 if datum
        end
      end
      @page.save
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected

  def find_page
    @page = Item.find(params[:page_id])
    if params[:parent_id]
      @parent = @page.data.find(params[:parent_id])
    else
      @parent = @page
    end
  end

end