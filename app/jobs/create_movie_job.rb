# frozen_string_literal: true

class CreateMovieJob < JobsBase
  extend Dry::Initializer
  option :video, Types::Integer
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
    @create_status ||= CreateMkvService.new(disk_title: disk_title, video: video).call
  end

  def video
    @video ||= video_type.constantize.find(video_id)
  end

  def renamed_file_path
    File.rename(create_status.mkv_path, create_status.dir.join("#{video.title}.mkv"))
  end
end
