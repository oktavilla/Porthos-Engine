class Admin::LinkListsController < ApplicationController
  respond_to :html
  include Porthos::Admin

  def new
    @link_list = LinkList.new
  end

  def create
    @link_list = LinkList.new(params[:link_list])
    if @link_list.save
      flash[:notice] = I18n.t(:'app.admin_general.saved')
    end
    respond_with(@link_list)
  end

  def show
    @link_list = LinkList.find(params[:id])
    respond_with @link_list
  end

  def edit
    @link_list = LinkList.find(params[:id])
  end

  def update
    @link_list = LinkList.find(params[:id])
    if @link_list.update_attributes(params[:link_list])
      flash[:notice] = I18n.t(:'app.admin_general.saved')
    end
    respond_with(@link_list, :location => admin_link_list_path(@link_list))
  end

  def destroy
    @link_list = LinkList.find(params[:id])
    if @link_list.destroy
      flash[:notice] = I18n.t(:'app.admin_general.deleted')
    end
    respond_with(@link_list, :location => admin_link_lists_path)
  end
end