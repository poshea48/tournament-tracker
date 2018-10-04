Rails.application.routes.draw do

  root to: 'tournaments#index'
  resources :tournaments

  get   '/tournaments/:id/add_team',     to: 'tournaments#add_team', as: :add_team
  post   '/tournaments/:id/add_team',    to: 'tournaments#add_to_tournament'
  delete '/tournaments/:id/delete_team', to: 'tournaments#delete_team', as: :delete_team

  get   '/tournaments/:id/poolplay',           to: 'poolplays#index', as: :poolplay
  get   '/tournaments/:id/poolplay/new',       to: 'poolplays#new',   as: :new_poolplay
  get   '/tournaments/:id/poolplay/temp_pool', to: 'poolplays#create_temporary_pool', as: :create_temp_pool
  post  '/tournaments/:id/poolplay',           to: 'poolplays#create'
  get   '/tournametns/:id/poolplay/edit',      to: 'poolplays#edit',  as: :results_poolplay
  patch '/tournaments/:id/poolplay',           to: 'poolplays#update'
  put   '/tournaments/:id/poolplay',           to: 'poolplays#update'
  get   '/tournaments/:id/leaderboard',        to: 'poolplays#leaderboard', as: :leaderboard

  get   '/tournaments/:id/playoffs',             to: 'poolplays#playoffs', as: :playoffs
  post  '/tournaments/:id/playoffs',             to: 'poolplays#create_playoff_pool'
  patch '/tournaments/:id/playoffs',             to: 'poolplays#update_playoffs'
  put   '/tournaments/:id/playoffs',             to: 'poolplays#update_playoffs'
  get   '/tournametns/:id/playoffs/edit',        to: 'poolplays#edit',  as: :results_playoffs

  get   '/tournaments/:id/final_results',        to: 'poolplays#final_results', as: :final_results


  # resources :users
  get '/players',          to: 'users#index'
  get '/signup',           to: 'users#new'
  post '/signup',          to: 'users#create'
  get '/players/:id',      to: 'users#show', as: :player
  get '/players/:id/edit', to: 'users#edit', as: :edit_player
  patch '/players/:id',    to: 'users#update'
  put '/players/:id',      to: 'users#update'


  get  '/login',  to: 'sessions#new'
  post '/login',  to: 'sessions#create'
  get  '/logout', to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
