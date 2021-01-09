# frozen_string_literal: true

class TheMovieDbsController < ApplicationController

  def index
    Movie.insert_all
    TV
    @movies = Movie.
  end

  private

  def search
    @search ||= TheMovieDb::Search::Multi.new(query: params.dig(:search, :query)).body
  end
end
