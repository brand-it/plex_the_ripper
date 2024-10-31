# frozen_string_literal: true

class MovieDiskTitleSelectorService < ApplicationService
  Info = Data.define(
    :disk_title,
    :extra_type,
    :within_range,
    :ripped?,
    :uploaded?
  )

  option :disk, Types.Instance(Disk)
  option :movie, Types.Instance(Movie)

  def call
    disk_title_sorted.map do |disk_title|
      Info.new(
        disk_title,
        extra_type(disk_title),
        within_range?(disk_title),
        ripped?(disk_title),
        uploaded?(disk_title)
      )
    end
  end

  private

  def extra_type(disk_title)
    if uploaded?(disk_title)
      nil
    elsif featured_file_disk_title&.id == disk_title.id
      'feature_films'
    elsif !within_range?(disk_title) && disk_title.angle.nil?
      'other'
    elsif !within_range?(disk_title)
      'shorts'
    end
  end

  def featured_file_disk_title
    @featured_file_disk_title ||= begin
      within_range_titles = disk.disk_titles.select { within_range?(_1) }.sort_by { _1.angle.to_i }
      within_range_titles.find { _1.angle&.positive? } || within_range_titles.first
    end
  end

  def ripped?(disk_title)
    movie.ripped_disk_titles.any? { _1.filename == disk_title.filename }
  end

  def uploaded?(disk_title)
    movie.ripped_disk_titles.find { _1.filename == disk_title.filename }&.video_blob&.uploaded? || false
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
