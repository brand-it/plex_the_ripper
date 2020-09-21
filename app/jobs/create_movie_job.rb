# frozen_string_literal: true

class CreateMovieJob < JobsBase
  extend Dry::Initializer
  option :video_id, Types::Integer
  option :video_type, Types::String

  def call
    create_mkv
  end

  def video
    @video ||= video_type.constantize.find(video_id)
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
