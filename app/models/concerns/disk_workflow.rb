# frozen_string_literal: true

module DiskWorkflow
  extend ActiveSupport::Concern
  included do # rubocop:disable Metrics/BlockLength
    include Workflow
    belongs_to :disk, optional: true
    belongs_to :disk_title, optional: true
    scope :selected, -> { where(workflow_state: 'selected') }
    scope :ripping, -> { where(workflow_state: 'ripping') }
    scope :failed, -> { where(workflow_state: 'failed') }
    scope :completed, -> { where(workflow_state: 'completed') }

    workflow do
      state :new do
        event :select, transitions_to: :selected
      end
      state :selected do
        event :cancel, transitions_to: :new
        event :rip, transitions_to: :ripping
      end
      state :ripping do
        event :fail, transitions_to: :failed
        event :complete, transitions_to: :completed
      end
      state :failed do
        event :cancel, transitions_to: :new
        event :rip, transitions_to: :ripping
      end
      state :completed
    end

    def load_workflow_state
      self[:workflow_state]
    end

    def persist_workflow_state(new_value)
      update!(workflow_state: new_value)
    end

    def select(disk_title:)
      halt! 'disk title & disk is required' if disk_title&.disk.nil?

      self.disk_title = disk_title
      self.disk = disk_title.disk
    end

    def complete(file_path:)
      self.file_path = file_path
    end
  end
end
