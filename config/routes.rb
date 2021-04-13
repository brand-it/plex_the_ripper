# frozen_string_literal: true

Rails.application.routes.draw do
  concern :disk_workflow do
    get :select, on: :collection
    get :rip, on: :member
  end

  resources :users
  #--------#
  # Config #
  #--------#
  namespace :config do
    resources :users, only: %i[edit update create new]
    resource :plex do
      member { get 'directories' }
    end
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
  resources :movies, concerns: :disk_workflow

  #----------#
  # TV Shows #
  #----------#
  resources :tvs
  resources :seasons
  resources :episodes, concerns: :disk_workflow

  resources :disks, only: [:index]
  resource :start
  resources :jobs, only: %i[index show]
  root to: 'start#new'
end
