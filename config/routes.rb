# frozen_string_literal: true

Rails.application.routes.draw do
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
  resources :movies

  #----------#
  # TV Shows #
  #----------#
  resources :tvs
  resources :seasons
  resources :episodes

  resources :disks, only: [:index]
  resources :disk_titles, only: %i[update show]
  resource :start
  resources :jobs, only: %i[index show]

  get 'images/:dimension/:filename', to: 'images#show', as: :image

  root to: 'start#new'
end
