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
FactoryBot.define do
  factory :disk do
    video
    episode
    disk_name { '/dev/rdisk5' }
  end
end
