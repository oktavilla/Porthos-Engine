Dummy::Application.routes.draw do
  resources :posts do
    collection do
      get 'contact'
    end
  end
  resources :authors do
    collection do
      get 'contact'
    end
  end
end
