class FilePathBuilder
  attr_reader :path

  def initialize
    @path = build_path
  end

  private

  def build_path
    if Config.configuration.type == :tv
      [
        Config.configuration.file_path,
        'TV Shows',
        Config.configuration.movie_name,
        Config.configuration.tv_season_to_word,
        Config.configuration.disc_number_to_word
      ]
    else
      [
        Config.configuration.file_path,
        'Movies',
        Config.configuration.movie_name
      ]
    end
  end
end
