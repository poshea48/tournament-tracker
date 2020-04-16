Rails.application.routes.draw do

  get 'landing/index'
  get 'games/index'
  get 'playoffs/index'
  get 'playoffs/new'
  get 'playoff/index'
  get 'playoff/new'
  root to: 'landing#index'
  resources :tournaments
  get '/tournaments', to: 'tournaments#index'
  get    '/tournaments/:id/add_team',    to: 'tournaments#add_team', as: :add_team
  post   '/tournaments/:id/add_team',    to: 'tournaments#add_to_tournament'
  delete '/tournaments/:id/delete_team', to: 'tournaments#delete_team', as: :delete_team

  get   '/tournaments/:id/poolplay',           to: 'poolplays#index', as: :poolplay
  get   '/tournaments/:id/poolplay/new',       to: 'poolplays#new',   as: :new_poolplay
  get   '/tournaments/:id/poolplay/temp_pool', to: 'poolplays#create_temporary_pool', as: :create_temp_pool
  post  '/tournaments/:id/poolplay',           to: 'poolplays#create'
  get   '/tournaments/:id/poolplay/edit',      to: 'poolplays#edit',  as: :results_poolplay
  patch '/tournaments/:id/poolplay',           to: 'poolplays#update'
  put   '/tournaments/:id/poolplay',           to: 'poolplays#update'
  post  '/tournaments/:id/poolplay_finished',  to: 'poolplays#poolplay_finished', as: :poolplay_finished
  get   '/tournaments/:id/poolplay/leaderboard',   to: 'poolplays#leaderboard', as: :poolplay_leaderboard

  get   '/tournaments/:id/playoffs',             to: 'playoffs#index', as: :playoffs
  post  '/tournaments/:id/playoffs',             to: 'playoffs#create'
  get   '/tournaments/:id/playoffs/edit',        to: 'playoffs#edit',  as: :results_playoffs
  patch '/tournaments/:id/playoffs',             to: 'playoffs#update'
  put   '/tournaments/:id/playoffs',             to: 'playoffs#update'
  post  '/tournaments/:id/playoffs_finished',    to: 'playoffs#playoffs_finished', as: :playoffs_finished
  get   '/tournaments/:id/final_results',        to: 'playoffs#final_results', as: :final_results
  get   '/tournaments/:id/playoffs/leaderboard', to: 'playoffs#leaderboard', as: :playoffs_leaderboard


  # resources :users
  get '/players',          to: 'users#index'
  get '/signup',           to: 'users#new', as: :new_session
  post '/signup',          to: 'users#create'
  get '/players/:id',      to: 'users#show', as: :player
  get '/players/:id/edit', to: 'users#edit', as: :edit_player
  patch '/players/:id',    to: 'users#update'
  put '/players/:id',      to: 'users#update'

  get   '/players/:id/edit_password', to: 'users#edit_password', as: :edit_password
  patch '/players/:id/edit_password', to: 'users#update_password'
  put   '/players/:id/edit_password', to: 'users#update_password'




  get  '/login',  to: 'sessions#new'
  post '/login',  to: 'sessions#create'
  get  '/logout', to: 'sessions#destroy'

  mount ActionCable.server, at: '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
