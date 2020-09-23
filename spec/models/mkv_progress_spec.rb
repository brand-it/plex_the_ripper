# frozen_string_literal: true

# == Schema Information
#
# Table name: mkv_progresses
#
#  id           :integer          not null, primary key
#  completed_at :datetime
#  failed_at    :datetime
#  name         :string
#  percentage   :float
#  video_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  disk_id      :integer
#  video_id     :integer
#
# Indexes
#
#  index_mkv_progresses_on_disk_id                  (disk_id)
#  index_mkv_progresses_on_video_type_and_video_id  (video_type,video_id)
#
require 'rails_helper'

RSpec.describe MkvProgress, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
