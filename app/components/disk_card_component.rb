# frozen_string_literal: true

class DiskCardComponent < ViewComponent::Base
  def initialize(disks:, movie: nil, in_progress: LoadDiskJob.process_pending?) # rubocop:disable Lint/MissingSuper
    @disks = disks
    @movie = movie
    @in_progress = in_progress
  end
end
