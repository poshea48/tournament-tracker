Rails.application.routes.draw do
  root to: 'tournaments#index'
  resources :tournaments

  resources :users
  get '/signup' => 'users#new'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
