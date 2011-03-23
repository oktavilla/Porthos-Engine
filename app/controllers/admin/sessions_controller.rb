# This controller handles the login/logout function of the site.
class Admin::SessionsController < ApplicationController
  include Porthos::Admin

  layout 'admin/sessions'

  def index
    redirect_to admin_dashboard_path
  end

  # render new.html.erb
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/admin')
    else
      flash[:error] = t(:login_failed, :scope => [:app, :admin_general])
      redirect_to admin_login_path
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t(:logged_out, :scope => [:app, :admin_general])
    redirect_to admin_login_path
  end

end
