# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  ejected        :boolean          default(TRUE), not null
#  loading        :boolean          default(FALSE), not null
#  name           :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  episode_id     :integer
#  video_id       :integer
#
# Indexes
#
#  index_disks_on_episode_id  (episode_id)
#  index_disks_on_video       (video_id)
#
class Disk < ApplicationRecord
  include Wisper::Publisher

  after_commit { broadcast(:disk_updated, self) }

  has_many :disk_titles, dependent: :nullify, autosave: true
  has_many :not_ripped_disk_titles, -> { not_ripped }, dependent: false, inverse_of: :disk, class_name: 'DiskTitle'
  belongs_to :video, optional: true
  belongs_to :episode, optional: true

  validates :disk_name, presence: true

  scope :ejected, -> { where(ejected: true) }
  scope :loading, -> { where(loading: true) }
  scope :not_ejected, -> { where(ejected: false) }
  scope :not_loading, -> { where(loading: false) }
  class << self
    include Shell

    def verified_disks
      index = 0
      devices.reduce(Disk.not_ejected) do |disks, device|
        disk_name = [device.disc_name, device.rdisk_name]
        name = device.drive_name
        if index.zero?
          disks.where(name:, disk_name:)
        else
          disks.or(Disk.not_ejected.where(name:, disk_name:))
        end.tap { index += 1 }
      end
    end
  end
end
