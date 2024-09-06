# frozen_string_literal: true

class MovieTitleTableComponent < ViewComponent::Base
  extend Dry::Initializer
  include IconHelper

  option :disks, Types::Coercible::Array.of(Types.Instance(Disk))
  option :movie, Types.Instance(Movie)

  def dom_id
    "#{self.class.name.parameterize}-#{movie.id}"
  end

  def disks_loading
    @disks_loading ||= Disk.loading
  end

  def disk_titles_with_info
    MovieDiskTitleSelectorService.call(movie:, disk:)
  end

  def disk
    @disk ||= disks.first
  end

  def free_disk_space
    @free_disk_space ||= stats.block_size * stats.blocks_available
  end

  def total_disk_space
    @total_disk_space ||= stats.block_size * stats.blocks
  end

  def job
    Job.sort_by_created_at.active.find_by(name: 'LoadDiskWorker')
  end

  def feature_film_selected!
    @feature_film_selected = true
  end

  def feature_film_selected?
    @feature_film_selected == true
  end

  private

  def stats
    @stats ||= Sys::Filesystem.stat('/')
  end
end
