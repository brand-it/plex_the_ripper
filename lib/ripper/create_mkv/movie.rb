# frozen_string_literal: true

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
      end
    end

    def add_to_movies
      videos = Config.configuration.videos
      videos.add_movie(name: Config.configuration.video_name)
    end

    # The index is the number or title in the list. This helps if
    def rename_mkv(mkv_file_name:, index:)
      number = format('%02d', index)
      movie_name = if index > 0
                     "#{Config.configuration.video_name} - #{number}.mkv"
                   else
                     "#{Config.configuration.video_name}.mkv"
                   end.delete('/:\\')
      old_name = File.join([directory, mkv_file_name])
      new_name = File.join([directory, movie_name])
      File.rename(old_name, new_name)
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
