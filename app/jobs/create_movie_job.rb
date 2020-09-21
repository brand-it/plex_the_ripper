# frozen_string_literal: true

class CreateMovieJob < JobsBase
  extend Dry::Initializer
  option :movie, Types.Instance(Movie)
  option :disk_title, Types.Instance(DiskTitle)

  def call
    if create_status.success?
      video.complete!(file_path: renamed_file_path)
    else
      video.fail!
    end
  end

  private

  def create_status
    @create_status ||= CreateMkvService.new(disk_title: disk_title, video: movie).call
  end

  def renamed_file_path
    File.rename(create_status.mkv_path, create_status.dir.join("#{movie.title}.mkv"))
  end
end
