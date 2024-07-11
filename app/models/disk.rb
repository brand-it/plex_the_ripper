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

  has_many :disk_titles, dependent: :destroy, autosave: true
  has_many :not_ripped_disk_titles, -> { not_ripped }, dependent: false, inverse_of: :disk, class_name: 'DiskTitle'
  belongs_to :video, optional: true
  belongs_to :episode, optional: true

  validates :disk_name, presence: true

  scope :ejected, -> { where(ejected: true) }
  scope :loading, -> { where(loading: true) }
  scope :not_ejected, -> { where(ejected: false) }
  scope :not_loading, -> { where(loading: false) }

  def disk_info
    @disk_info ||= DiskInfoService.new(disk_name:).results
  end
end
