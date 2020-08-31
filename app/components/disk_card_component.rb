# frozen_string_literal: true

class DiskCardComponent < ViewComponent::Base
  def initialize(disks:) # rubocop:disable Lint/MissingSuper
    @disks = disks
  end
end
