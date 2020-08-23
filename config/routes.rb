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
    resources :the_movie_dbs, only: %i[edit update create new]
  end
  resources :the_movie_dbs, only: %i[index show]
  resources :movies
  resources :tvs
  resources :seasons
  resource :start
  root to: 'start#new'
end
