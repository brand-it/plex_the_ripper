# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id                :integer          not null, primary key
#  completed_at      :datetime
#  failed_at         :datetime
#  message           :text
#  name              :string
#  percentage        :float
#  progressable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  disk_id           :bigint
#  disk_title_id     :bigint
#  progressable_id   :bigint
#
# Indexes
#
#  index_mkv_progresses_on_disk_id                                (disk_id)
#  index_mkv_progresses_on_disk_title_id                          (disk_title_id)
#  index_mkv_progresses_on_progressable_type_and_progressable_id  (progressable_type,progressable_id)
#
FactoryBot.define do
  factory :mkv_progress do
    video
    disk_title
    disk
  end
end
