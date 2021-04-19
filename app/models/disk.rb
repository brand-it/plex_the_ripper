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

  workflow do
    state :new do
      event :load_titles, transitions_to: :completed
    end
    state :completed do
      state :restart, transitions_to: :new
    end
  end

  scope :completed, -> { where(workflow_state: :completed) }

  def completed; end

  def restart
    disk_titles.destroy_all
  end
end
