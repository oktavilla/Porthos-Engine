Rails.application.routes.draw do
  mount Porthos::Middleware::TagsAutocompleteApp.instance => '/admin/tags/autocomplete'

  filter :url_resolver

  resources :pages do
    collection do
      get 'categories'
    end
    member do
      get 'preview'
    end
  end
  get 'pages/:id/category' => 'pages#category', :as => 'pages_category'

  namespace :admin do
    root :to => 'dashboard#index'
    get '/login' => 'sessions#new', :as => 'login'
    get '/logout' => 'sessions#destroy', :as => 'logout'
    resources :sessions
    resources :users do
      collection do
        get 'admins'
        get 'search'
      end
    end

    resources :site_settings
    resources :redirects
    resources :tags
    resources :display_options do
      collection do
        put :sort
      end
    end

    resources :nodes do
      member do
        get 'place'
        put 'toggle'
      end
      collection do
        put 'sort'
      end
    end

    resources :link_lists do
      resources :links do
        collection do
          put 'sort'
        end
      end
    end

    resources :templates do
      resources :datum_templates do
        collection do
          put 'sort'
        end
      end
    end
    resources :page_templates do
      collection do
        put 'sort'
      end
    end
    resources :content_templates do
      collection do
        put 'sort'
      end
    end

    resources :items do
      collection do
        get 'search'
        put 'sort'
      end
      member do
        put 'toggle'
        put 'publish'
      end
      resources :data do
        collection do
          put 'sort'
        end
        member do
          put 'toggle'
          get 'settings'
        end
      end
    end

    resources :assets do
      collection do
        get 'search'
        get 'incomplete'
        put 'update_multiple'
      end
      member do
        get 'edit_cropping'
      end
    end
  end
end
