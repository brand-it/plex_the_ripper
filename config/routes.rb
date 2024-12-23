# frozen_string_literal: true

Rails.application.routes.draw do
  resource :system, only: [] do
    patch :restart
    get :wait
    get :health
  end
  resources :users do
    member { get :login }
  end
  #--------#
  # Config #
  #--------#
  namespace :config do
    resource :plex do
      member { get 'directories' }
    end
    resource :slack, only: %i[edit update create new]
    resource :the_movie_db, only: %i[edit update create new]
    resource :make_mkv, only: %i[edit update create new] do
      collection { get :install }
    end
  end
  resources :the_movie_dbs, only: %i[index] do
    collection { post 'next_page' }
  end

  #--------#
  # Movies #
  #--------#
  resources :movies do
    member do
      post :rip
      post :auto_start
      post :cancel_auto_start
    end
  end

  #----------#
  # TV Shows #
  #----------#
  resources :tvs do
    resources :seasons do
      member { post :rip }
    end
  end

  resources :disks, only: [:index] do
    member { post :eject }
  end

  resource :start
  resources :jobs, only: %i[index show]

  get 'images/:dimension/:filename', to: 'images#show', as: :image

  root to: 'start#new'
end
