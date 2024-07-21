# frozen_string_literal: true

class LoadDiskProcessComponent < ViewComponent::Base
  extend Dry::Initializer

  option :message, Types::String.optional, optional: true

  def disks_loading
    @disks_loading ||= Disk.loading
  end

  def disks_not_ejected
    @disks_not_ejected ||= Disk.not_ejected
  end

  def dom_id
    'load-disk-process-component'
  end
end
