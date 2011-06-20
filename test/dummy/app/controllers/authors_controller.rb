class AuthorsController < ActionController::Base
   def show
     url = author_path(params)
     render :text => params.merge(:url => url).inspect
   end
end
