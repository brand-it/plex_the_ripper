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
  has_many :disk_titles, dependent: :destroy
  has_many :episodes, dependent: :nullify
  has_one :movie, dependent: :nullify

  before_update :destroy_disk_titles, if: :disk_name_changed?

  def self.all_valid?
    Rails.cache.fetch(Disk.all.cache_key, namespace: 'v1/all_valid', expires_in: 1.minute) do
      Disk.all.pluck(:disk_name) == ListDrivesService.new.call
    end
  end

  private

  def destroy_disk_titles
    disk_titles.destroy_all
  end
end
