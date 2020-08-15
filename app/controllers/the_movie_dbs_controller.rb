# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  def index
    render search_results
  end

  private

  def search_results
    TheMovieDb::Search::Movie.new(query: params[:query]).results +
      TheMovieDb::Search::Tv.new(query: params[:query]).results
  end
end
