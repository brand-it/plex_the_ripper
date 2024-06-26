# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  ejected        :boolean          default(TRUE), not null
#  name           :string
#  video_type     :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  episode_id     :integer
#  video_id       :integer
#
# Indexes
#
#  index_disks_on_episode_id  (episode_id)
#  index_disks_on_video       (video_type,video_id)
#
class Disk < ApplicationRecord
  include Wisper::Publisher

  after_commit { broadcast(:disk_updated, self) }

  has_many :disk_titles, dependent: :destroy, autosave: true
  belongs_to :video, polymorphic: true
  belongs_to :episode

  validates :disk_name, presence: true

  scope :not_ejected, -> { where(ejected: false) }
  scope :ejected, -> { where(ejected: true) }

  def disk_info
    @disk_info ||= DiskInfoService.new(disk_name:).results
  end
end
