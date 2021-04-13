# frozen_string_literal: true

class TheMovieDbsController < ApplicationController
  helper_method :search_service

  def index; end

  def next_page
    respond_to do |format|
      format.turbo_stream { render layout: false }
      format.html { render :index }
    end
  end

  private

  def search_service
    @search_service ||= VideoSearchService.new(query: params.dig(:search, :query), page: params.dig(:search, :page))
  end
end
