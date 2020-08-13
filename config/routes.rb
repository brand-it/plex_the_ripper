# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :config do
    resources :users, only: %i[edit update create new]
    resources :the_movie_dbs, only: %i[edit update create new]
  end
  resources :configs

  root to: 'configs#new'
end
