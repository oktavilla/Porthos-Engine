class Admin::UsersController < ApplicationController
  include Porthos::Admin

  def index
    @users = apply_scopes(User).page(params[:page])
    respond_to do |format|
      format.html
      end
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
    @user.save!
    flash[:notice] = "#{@user.name} #{t(:saved, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to params[:return_to] || admin_users_path }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "#{@user.name} #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to params[:return_to] || admin_users_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "#{@user.name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

end