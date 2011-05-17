Rails.application.routes.draw do
  mount AssetServer.instance => '/assets/admin'

  filter :url_resolver
  resources :pages do
    collection do
      get 'categories'
    end
    member do
      get 'preview'
    end
  end
  match 'pages/categories/:id' => 'pages#category', :as => 'pages_category'

  namespace :admin do
    root :to => 'pages#index'
    match 'login' => 'sessions#new', :as => 'login'
    match '/logout' => 'sessions#destroy', :as => 'logout'
    resources :sessions
    resources :users do
      collection do
        get 'admins'
        get 'public'
        get 'new_public'
        get 'search'
      end
    end

    resources :site_settings
    resources :redirects
    resources :tags

    resources :nodes do
      member do
        get 'place'
      end
      collection do
        put 'sort'
      end
    end

    resources :templates do
      resources :datum_templates do
        collection do
          put 'sort'
        end
      end
    end
    resources :page_templates
    resources :content_templates

    resources :pages do
      collection do
        get 'search'
        put 'sort'
      end
      member do
        put 'publish'
      end
      resources :data do
        resources :contents do
          collection do
            put 'sort'
          end
          member do
            put 'toggle'
            get 'settings'
          end
        end
      end
    end

    resources :assets do
      collection do
        get 'search'
        get 'incomplete'
        put 'update_multiple'
      end
    end
  end
end