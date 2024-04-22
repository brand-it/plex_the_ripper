# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Config::PlexesController do
  describe 'routing' do
    # it "routes to #index" do
    #   expect(get: "/config/plexes").to route_to("config/plexes#index")
    # end

    it 'routes to #new' do
      expect(get: '/config/plex/new').to route_to('config/plexes#new')
    end

    # it "routes to #show" do
    #   expect(get: "/config/plexes/1").to route_to("config/plexes#show", id: "1")
    # end

    it 'routes to #edit' do
      expect(get: '/config/plex/edit').to route_to('config/plexes#edit')
    end

    it 'routes to #create' do
      expect(post: '/config/plex').to route_to('config/plexes#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/config/plex').to route_to('config/plexes#update')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/config/plex').to route_to('config/plexes#update')
    end

    # it "routes to #destroy" do
    #   expect(delete: "/config/plexes/1").to route_to("config/plexes#destroy", id: "1")
    # end
  end
end
