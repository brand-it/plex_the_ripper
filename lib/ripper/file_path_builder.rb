class FilePathBuilder
  attr_reader :path

  def initialize
    @path = build_path
  end

  private

  def build_path
    if Config.configuration.type == :tv
      [
        Config.configuration.media_directory_path,
        Config.configuration.tv_shows_directory_name,
        Config.configuration.video_name,
        Config.configuration.tv_season_to_word,
        Config.configuration.disc_number_to_word
      ]
    else
      [
        Config.configuration.media_directory_path,
        'Movies',
        Config.configuration.video_name
      ]
    end
  end
end
