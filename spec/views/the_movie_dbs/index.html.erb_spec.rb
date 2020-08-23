# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the_movie_dbs/index', type: :view do
  let(:search) { TheMovieDb::Search::Multi.new(query: nil) }

  before { assign(:search, search) }

  it 'renders a list of movies' do
    render
    expect(rendered).to match(/Get started by typing in the name of the TV show or movie./)
  end
end
