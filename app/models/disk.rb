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
  include PersistedWorkflow

  after_commit { broadcast(:disk_updated, self) }

  has_many :disk_titles, dependent: :destroy
  has_many :episodes, dependent: :nullify
  has_one :movie, dependent: :nullify

  workflow do
    state :new do
      event :load_titles, transitions_to: :completed
    end
    state :completed do
      state :restart, transitions_to: :new
    end
  end

  scope :completed, -> { where(workflow_state: :completed) }

  def self.percentage_completed
    total = count.to_f
    return 0 if total.zero?

    ((completed.count / total) * 100).to_i
  end

  def self.all_valid?
    # Rails.cache.fetch(Disk.all, namespace: 'all_valid', expires_in: 10.seconds) do
    Disk.all.pluck(:disk_name) == ListDrivesService.new.results
    # end
  end

  def load_titles
    DiskInfoService.new(disk_name: disk_name).results.each do |title|
      disk_titles.create!(
        title_id: title.id,
        name: title.file_name,
        size: title.size,
        duration: title.duration_seconds
      )
    end
  end

  def restart
    disk_titles.destroy_all
  end
end
