class Admin::UsersController < ApplicationController
  respond_to :html
  include Porthos::Admin

  def index
    @users = apply_scopes(User).page(params[:page])
    respond_with @users
  end

  def search
    query = params[:query]
    page  = params[:page] || 1
    @search = User.search do
      keywords(query)
      paginate :page => page
    end
    @query = query
    @page = page
    respond_to do |format|
      format.html
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "#{@user.name} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @user, :location => (params[:return_to] || admin_users_path)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user.name} #{t(:saved, :scope => [:app, :admin_general])}"
    end
    respond_with @user, :location => (params[:return_to] || admin_users_path)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "#{@user.name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_with @user, :location => (params[:return_to] || admin_users_path)
  end

end