# frozen_string_literal: true

class ImagesController < ApplicationController
  HOST_URL = 'https://image.tmdb.org/t/p'
  def show
    send_data image, disposition: :inline, type: "image/#{params[:format]}"
  end

  private

  # Store the image in a cache directory on localhost to avoid multiple requests
  def image
    Rails.cache.fetch(image_url, namespace: :images) do
      Net::HTTP.get(image_url)
    end
  end

  def image_url
    URI.parse("#{HOST_URL}/#{params[:dimension]}/#{params[:filename]}.#{params[:format]}")
  end
end
