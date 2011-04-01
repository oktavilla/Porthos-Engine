class Admin::UsersController < ApplicationController
  include Porthos::Admin
  before_filter :login_required

  has_scope :role, :default => 'Admin'

  def index
    @users = apply_scopes(User).paginate({
      :page     => (params[:page] || 1),
      :per_page => (params[:per_page] || 90)
    })
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
    @role = Role.find_or_create_by_name('Admin')
  end

  def new_public
    @user = User.new
    @role = Role.find_or_create_by_name('Public')
    render :action => 'new'
  end

  def create
    @user = User.new(params[:user])
    @role = Role.find_or_create_by_name(params[:role])
    @user.roles << @role
    @user.save!
    flash[:notice] = "#{@user.login} #{t(:saved, :scope => [:app, :admin_general])}"
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
    raise SecurityTransgression unless current_user.can_edit?(@user)
  end

  def update
    @user = User.find(params[:id])
    raise SecurityTransgression unless current_user.can_edit?(@user)
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
    raise SecurityTransgression unless current_user.can_destroy?(@user)
    @user.destroy
    flash[:notice] = "#{@user.login} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

end
