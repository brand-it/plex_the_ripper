# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id              :integer          not null, primary key
#  duration        :integer
#  name            :string           not null
#  size            :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  disk_id         :bigint
#  mkv_progress_id :bigint
#  title_id        :integer          not null
#
# Indexes
#
#  index_disk_titles_on_disk_id          (disk_id)
#  index_disk_titles_on_mkv_progress_id  (mkv_progress_id)
#
class DiskTitle < ApplicationRecord
  has_one :movie, dependent: :nullify
  has_one :episode, dependent: :nullify
  belongs_to :disk

  validates :disk, presence: true

  def video
    movie || episode
  end
end
