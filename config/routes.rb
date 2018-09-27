Rails.application.routes.draw do

  root to: 'tournaments#index'
  resources :tournaments

  get  '/tournaments/:id/add_team', to: 'tournaments#add_team', as: :add_team
  post '/tournaments/:id/add_team', to: 'tournaments#add_to_tournament'

  get   '/tournaments/:id/poolplay',           to: 'poolplays#index', as: :poolplay
  get   '/tournaments/:id/poolplay/new',       to: 'poolplays#new',   as: :new_poolplay
  get   '/tournaments/:id/poolplay/temp_pool', to: 'poolplays#create_temporary_pool', as: :create_temp_pool
  post  '/tournaments/:id/poolplay',           to: 'poolplays#create'
  get   '/tournametns/:id/poolplay/edit',      to: 'poolplays#edit',  as: :edit_poolplay
  patch '/tournaments/:id/poolplay/edit',      to: 'poolplays#update'
  put   '/tournaments/:id/poolplay/edit',      to: 'poolplays#update'


  resources :users
  get '/signup' => 'users#new'

  get  '/login',  to: 'sessions#new'
  post '/login',  to: 'sessions#create'
  get  '/logout', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
