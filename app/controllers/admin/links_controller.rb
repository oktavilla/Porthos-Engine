class Admin::LinksController < ApplicationController
  respond_to :html
  include Porthos::Admin

  before_filter :find_link_list

  def new
    @link = @link_list.links.build
  end

  def create
    @link = @link_list.links.build(params[:link])
    if @link.save
      flash[:notice] = I18n.t(:'app.admin_general.saved')
    end
    respond_with(@link, :location => admin_link_list_path(@link_list))
  end

  def show
    @link = @link_list.links.find(params[:id])
    respond_with @link
  end

  def edit
    @link = @link_list.links.find(params[:id])
  end

  def update
    @link = @link_list.links.find(params[:id])
    if @link.update_attributes(params[:link])
      flash[:notice] = I18n.t(:'app.admin_general.saved')
    end
    respond_with(@link, :location => admin_link_list_path(@link_list))
  end

  def destroy
    @link = @link_list.links.find(params[:id])
    @link_list.links.delete_if { |link| link == @link }
    if @link_list.save
      flash[:notice] = I18n.t(:'app.admin_general.deleted')
    end
    respond_with(@link, :location => admin_link_list_path(@link_list))
  end

  def sort
    if params[:link]
      params[:link].each_with_index do |id, i|
        if link = @link_list.links.detect { |l| l.id.to_s == id }
          link.position = i+1
        end
      end
      @link_list.save
    end
    respond_to do |format|
      format.json { render :nothing => true }
    end
  end

protected

  def find_link_list
    @link_list = LinkList.find(params[:link_list_id])
  end

end