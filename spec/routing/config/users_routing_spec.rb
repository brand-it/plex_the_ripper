# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/config/users').to route_to('config/users#index')
    end

    it 'routes to #new' do
      expect(get: '/config/users/new').to route_to('config/users#new')
    end

    it 'routes to #show' do
      expect(get: '/config/users/1').to route_to('config/users#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/config/users/1/edit').to route_to('config/users#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/config/users').to route_to('config/users#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/config/users/1').to route_to('config/users#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/config/users/1').to route_to('config/users#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/config/users/1').to route_to('config/users#destroy', id: '1')
    end
  end
end
