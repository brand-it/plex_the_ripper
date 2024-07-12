# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/tvs' do
  before do
    create(:config_make_mkv)
    create(:config_the_movie_db)
    stub = instance_double(TheMovieDb::VideoListener, :tv_saving)
    allow(TheMovieDb::VideoListener).to receive(:new).and_return(stub)
  end

  describe '/:id' do
    let!(:tv) { create(:tv) }

    it 'renders a successful response' do
      get tv_url(tv)
      expect(response).to have_http_status :ok
    end
  end
end
