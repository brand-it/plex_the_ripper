# frozen_string_literal: true

class RenameMkvService
  extend Dry::Initializer

  option :disk_title, Types.Instance(DiskTitle)
  option :result, Types.Interface(:dir, :mkv_path)

  def call
    new_name = File.join([result.dir, movie_name])
    File.rename(result.mkv_path, new_name)
  end

  def movie_name
    "#{disk_title.movie.safe_name}.mkv"
  end
end
