# frozen_string_literal: true

class MovieDiskTitleSelectorService < ApplicationService
  Info = Data.define(:disk_title, :extra_type, :within_range, :ripped?, :uploaded?)

  option :disk, Types.Instance(Disk)
  option :movie, Types.Instance(Movie)

  def call
    disk_title_sorted.map do |disk_title|
      Info.new(
        disk_title,
        extra_type(disk_title), within_range?(disk_title),
        ripped?(disk_title), uploaded?(disk_title)
      )
    end
  end

  private

  def extra_type(disk_title)
    if uploaded?(disk_title)
      nil
    elsif within_range?(disk_title) && feature_film_selected?
      'shorts'
    elsif within_range?(disk_title)
      feature_film_selected!
      'feature_films'
    else
      'other'
    end
  end

  def ripped?(disk_title)
    movie.ripped_disk_titles.any? { _1.name == disk_title.name }
  end

  def uploaded?(disk_title)
    movie.ripped_disk_titles.find { _1.name == disk_title.name }&.video_blob&.uploaded? || false
  end

  def within_range?(disk_title)
    movie.runtime_range.include?(disk_title.duration)
  end

  def feature_film_selected!
    @feature_film_selected = true
  end

  def feature_film_selected?
    @feature_film_selected == true
  end

  def disk_title_sorted
    @disk_title_sorted ||= disk.disk_titles.sort_by do |disk_title|
      (movie.movie_runtime - disk_title.duration).abs
    end
  end
end
