class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

private
  def record_not_found
    render :file => 'shared/404', :status => 404
  end
end
