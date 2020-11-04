# frozen_string_literal: true

class CreateMovieWorker < ApplicationWorker
  # option :movie, Types.Instance(Movie)
  # option :disk_title, Types.Instance(DiskTitle)

  def call
    Rails.logger.info("Create Movie Worker: nil")
    (0..100).each do |percentage|
      Rails.logger.info("Create Movie Worker: #{percentage}")
      MkvProgress.last.update!(percentage: percentage)
      sleep 1
    end

    # if create_status.success?
      # movie.complete!(file_path: renamed_file_path)
    # else
      # movie.fail!
    # end
  end

  private

  def create_status
    @create_status ||= CreateMkvService.new(disk_title: disk_title, video: movie).call
  end

  def renamed_file_path
    File.rename(create_status.mkv_path, create_status.dir.join("#{movie.title}.mkv"))
  end
end
