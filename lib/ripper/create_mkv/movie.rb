class CreateMKV
  class Movie < Base
    DIRECTORY = File.join(
      Config.configuration.media_directory_path,
      Config.configuration.movies_directory_name
    )

    class << self
      def perform
        return if Config.configuration.type != :movie

        movie = CreateMKV::Movie.new
        movie.start!
        movie.create_mkv
        movie.rename_movies
        movie.finished!
        movie.notify_slack_success
      end
    end

    def create_mkv
      status = mkv_system!(title: Config.configuration.movie_title)
      process_status!(status)
    end

    def rename_movies
      movies = mkv_files.sort
      movies.each_with_index do |movie, index|
        number = format('%02d', index)
        movie_name = if movies.size > 1
                       "#{Config.configuration.video_name} - #{number}.mkv"
                     else
                       "#{Config.configuration.video_name}.mkv"
                     end
        old_name = File.join([directory, movie])
        new_name = File.join([directory, movie_name])
        File.rename(old_name, new_name)
      end
    end

    def check_for_multiple_movies
      return if Config.configuration.type == :tv

      if all_titles.size == 1
        @titles = [all_titles.first]
      elsif all_titles.size > 1
        Logger.warning('There was more then one movie found. Please Select one of the title above')
        @title_numbers = [Shell.ask_value_required(
          'Which one do you want to keep?(Title Number) ',
          type: Integer
        )]
      else
        Logger.warning 'Well this sucks I got zero titles for this disk'
        Logger.warning all_titles.inspect
        Logger.warning get_disk_info.inspect
      end
    end
  end
end
