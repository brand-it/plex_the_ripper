# frozen_string_literal: true

# == Schema Information
#
# Table name: disk_titles
#
#  id         :integer          not null, primary key
#  duration   :integer
#  name       :string           not null
#  size       :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  disk_id    :integer
#  title_id   :integer          not null
#
# Indexes
#
#  index_disk_titles_on_disk_id  (disk_id)
#
class DiskTitle < ApplicationRecord
  belongs_to :disk
  has_many :mkv_progresses
end
