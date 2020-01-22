# frozen_string_literal: true

class VideosLoader
  class << self
    def perform
      return if Config.configuration.videos.any?

      sleep 1 until Config.configuration.media_directory_path && File.exist?(Config.configuration.media_directory_path)
      Logger.info('Started Loading Videos')

      file_checker = VideosLoader.new
      file_checker.load_videos
    end
  end

  def load_videos
    videos = Videos.load
    videos[:movies].each do |movie_path|
      begin
        Config.configuration.videos.add_movie(**Movie.mkv_path_to_hash(movie_path))
      rescue Model::Validation => exception
        Logger.error("#{exception.message} #{movie_path} #{movie}")
      end
    end
    videos[:tv_shows].each do |tv_show_path|
      begin
        Config.configuration.videos.add_tv_show(TVShow.mkv_path_to_hash(tv_show_path))
      rescue Model::Validation => exception
        Logger.error("#{exception.message} #{tv_show_path} #{tv_show}")
      end
    end
  end

  private

  # Currently not being used... Could use this to help fix move data
  def warn_about_naming_issues(mkv_path, name_one, name_two)
    return if name_one.strip == name_two.strip

    Logger.warning(
      "#{mkv_path} expected to match but does not Please fix "\
      "#{name_one.inspect} != #{name_two.inspect}. Going to use #{name_one}",
      delayed: true
    )
  end
end
