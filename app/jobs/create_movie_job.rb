# frozen_string_literal: true

class CreateMovieJob < Jobs::Base
  extend Dry::Initializer
  param :video_id, Types::Integer
  param :video_type, proc(&:constantize)

  def call
    create_mkv
  end

  def video
    @video ||= video_type.find(video_id)
  end

  def rename_mkv(mkv_file_name:)
    number = format('%<index>2d', index)
    old_name = File.join([directory, mkv_file_name])
    new_name = File.join([directory, movie_name])
    File.rename(old_name, new_name)
  end

  def clean_video_name(name)
    name.delete('/:\\')
  end
end
