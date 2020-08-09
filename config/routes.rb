# frozen_string_literal: true

Rails.application.routes.draw do
  resources :configs
  resource :user_config

  root to: 'configs#new'
end
