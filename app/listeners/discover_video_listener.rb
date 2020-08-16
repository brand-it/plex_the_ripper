# frozen_string_literal: true

class DiscoverVideoListener
  def movie_saved(id)
    movie = Movie.find_by(id: id)
    return if movie.nil?
    movie
    movie.file_path =
  end


  private

  def config_plex
    @config ||= Confi::Plex.newest.first
  end

  def movie_path
    config_plex&.settings&.movie_path.tap do |path|
      raise "#{path} does not exist" unless File.exist?(path)
    end
  end
end
