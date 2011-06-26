class AuthorsController < ActionController::Base
   def index
     url = authors_path(params)
     render :text => params.merge(:url => url).inspect
   end

   def show
     url = author_path(params)
     render :text => params.merge(:url => url).inspect
   end

   def contact
     render :text => params.inspect
   end
end
