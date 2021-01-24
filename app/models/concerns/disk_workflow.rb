# frozen_string_literal: true

module DiskWorkflow
  extend ActiveSupport::Concern
  included do # rubocop:disable Metrics/BlockLength
    include PersistedWorkflow
    belongs_to :disk, optional: true
    has_many :disk_titles, as: :video, dependent: :destroy
    scope :selected, -> { where(workflow_state: 'selected') }
    scope :ripping, -> { where(workflow_state: 'ripping') }
    scope :failed, -> { where(workflow_state: 'failed') }
    scope :completed, -> { where(workflow_state: 'completed') }

    after_commit :only_one_selected

    workflow do
      state :new do
        event :select, transitions_to: :selected
      end
      state :selected do
        event :select_disk_titles, transitions_to: :ready_to_rip
        event :cancel, transitions_to: :new
      end
      state :ready_to_rip do
        event :cancel, transitions_to: :new
        event :rip, transitions_to: :ripping
      end
      state :ripping do
        event :fail, transitions_to: :failed
        event :complete, transitions_to: :completed
      end
      state :failed do
        event :retry, transitions_to: :ripping
      end
      state :completed
    end

    def only_one_selected
      self.class
          .selected
          .where.not(id: id)
          .update_all(workflow_state: nil) # rubocop:disable Rails/SkipsModelValidations
    end

    def select_disk_titles(disk_titles)
      halt! 'Disk Title is required' if disk_titles&.empty?

      self.disk_titles = disk_titles
    end
  end
end
