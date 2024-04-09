# frozen_string_literal: true

# == Schema Information
#
# Table name: disks
#
#  id             :integer          not null, primary key
#  disk_name      :string
#  name           :string
#  workflow_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Disk < ApplicationRecord
  include Wisper::Publisher

  after_commit { broadcast(:disk_updated, self) }

  has_many :disk_titles, dependent: :destroy

  def disk_info
    @disk_info ||= DiskInfoService.new(disk_name:).results
  end
end
