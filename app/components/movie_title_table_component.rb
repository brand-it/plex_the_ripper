# frozen_string_literal: true

class MovieTitleTableComponent < ViewComponent::Base
  extend Dry::Initializer
  include IconHelper

  option :disks, Types::Coercible::Array.of(Types.Instance(Disk))
  option :movie, Types.Instance(Movie)

  def dom_id
    "#{self.class.name.parameterize}-#{movie.id}"
  end

  def free_disk_space
    @free_disk_space ||= stats.block_size * stats.blocks_available
  end

  def total_disk_space
    @total_disk_space ||= stats.block_size * stats.blocks
  end

  private

  def stats
    @stats ||= Sys::Filesystem.stat('/')
  end
end
