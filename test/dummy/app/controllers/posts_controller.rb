class PostsController < ActionController::Base
  include Rails.application.routes.url_helpers if defined?(Rails)

  def index
    url = url_for(params.merge(:only_path => true))
    render :text => params.merge(:url => url).inspect
  end

  def show
    url = post_path(params)
    render :text => params.merge(:url => url).inspect
  end
end