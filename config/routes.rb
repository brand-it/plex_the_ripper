# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users
  namespace :config do
    resources :users, only: %i[edit update create new]
    resource :plex do
      member do
        get 'directories'
      end
    end
    resource :the_movie_db, only: %i[edit update create new]
    resource :make_mkv, only: %i[edit update]
  end
  resources :the_movie_dbs, only: %i[index show]
  resources :movies do
    member do
      patch :rip
    end
  end

  resources :tvs
  resources :seasons
  resources :episodes do
    collection { post 'select' }
  end
  resource :disk, only: [] do
    collection do
      get :reload
      get :build
    end
  end
  resource :start
  root to: 'start#new'
end
