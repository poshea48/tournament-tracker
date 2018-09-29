Rails.application.routes.draw do

  root to: 'tournaments#index'
  resources :tournaments

  get  '/tournaments/:id/add_team', to: 'tournaments#add_team', as: :add_team
  post '/tournaments/:id/add_team', to: 'tournaments#add_to_tournament'

  get   '/tournaments/:id/poolplay',             to: 'poolplays#index', as: :poolplay
  get   '/tournaments/:id/poolplay/new',         to: 'poolplays#new',   as: :new_poolplay
  get   '/tournaments/:id/poolplay/temp_pool',   to: 'poolplays#create_temporary_pool', as: :create_temp_pool
  post  '/tournaments/:id/poolplay',             to: 'poolplays#create'
  get   '/tournametns/:id/poolplay/edit',        to: 'poolplays#edit',  as: :results_poolplay
  patch '/tournaments/:id/poolplay',             to: 'poolplays#update'
  put   '/tournaments/:id/poolplay',             to: 'poolplays#update'
  get   '/tournaments/:id/leaderboard', to: 'poolplays#leaderboard', as: :leaderboard

  get   '/tournaments/:id/playoffs',             to: 'poolplays#playoffs', as: :playoffs
  post  '/tournaments/:id/playoffs',             to: 'poolplays#create_playoff_pool'
  patch '/tournaments/:id/playoffs',             to: 'poolplays#update_playoffs'
  put   '/tournaments/:id/playoffs',             to: 'poolplays#update_playoffs'
  get   '/tournametns/:id/playoffs/edit',        to: 'poolplays#edit',  as: :results_playoffs

  resources :users
  get '/signup' => 'users#new'

  get  '/login',  to: 'sessions#new'
  post '/login',  to: 'sessions#create'
  get  '/logout', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
