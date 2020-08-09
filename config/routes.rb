# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :config do
    resources :users
    resources :the_movie_dbs
  end
  resources :configs

  root to: 'configs#new'
end
