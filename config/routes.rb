Rails.application.routes.draw do
  resources :social_networks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root to: "homepage#index"
  get 'search', to: 'homepage#search'
  resources :users, only: [:index, :show]
end
