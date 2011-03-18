Dummy::Application.routes.draw do
  resources :tests
  filter :url_resolver
end
