# frozen_string_literal: true

Rails.application.routes.draw do
  resource :config

  root to: 'config#new'
end
