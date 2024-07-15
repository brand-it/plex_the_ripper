# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/movies' do
  before do
    create(:config_make_mkv)
    create(:config_the_movie_db)
    stub = instance_double(TheMovieDb::VideoListener, :movie_saving)
    allow(TheMovieDb::VideoListener).to receive(:new).and_return(stub)
  end

  describe '/:id/rip' do
    let!(:movie) { create(:movie) }
    let!(:disk_title) { create(:disk_title) }
    let(:disk_id) { disk_title.disk.id }

    it 'renders a successful response' do
      post rip_movie_url(movie),
           params: { disk_id:, movies: [{ extra_type: 'feature_film', disk_title_id: disk_title.id }] }
      expect(Job.count).to eq 1

      expect(response).to have_http_status :found
    end
  end

  describe '/:id' do
    let!(:movie) { create(:movie) }

    it 'renders a successful response' do
      get movie_url(movie)
      expect(response).to have_http_status :ok
    end
  end
end
