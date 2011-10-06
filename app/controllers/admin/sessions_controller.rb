# This controller handles the login/logout function of the site.
class Admin::SessionsController < ApplicationController
  include Porthos::Admin
  skip_before_filter :authenticate!
  layout 'admin/sessions'

  def index
    redirect_to admin_root_path
  end

  def new
  end

  def create
    user = warden.authenticate!
    sign_in user
    if params[:remember_me]
      cookies.permanent.signed[Porthos::Authentication::Strategies::Rememberable.cookie_name] = user.generate_remember_me_token!
    end
    flash[:notice] = t(:'admin.sessions.signed_in')
    redirect_to admin_root_path
  end

  def destroy
    sign_out
    flash[:notice] = t(:'admin.sessions.signed_out')
    redirect_to admin_login_path
  end

end
