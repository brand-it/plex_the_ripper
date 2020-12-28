# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  before_action :set_search, only: %i[index]

  def index
    # CreateMovieWorker.perform
    # MkvProgress.last.update!(percentage: 2 % MkvProgress.last.percentage)
  end

  private

  def set_search
    @search = TheMovieDb::Search::Multi.new(query: params.dig(:search, :query))
  end
end
