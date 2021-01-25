# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_params

  def index
    @videos = VideoSearchService.new(query: search_params.query).results
  end

  private

  def search_params
    OpenStruct.new(query: params.dig(:search, :query))
  end
end
