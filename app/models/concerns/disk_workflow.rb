# frozen_string_literal: true

module DiskWorkflow
  extend ActiveSupport::Concern

  included do
    include Workflow
    belongs_to :disk, optional: true

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
  end
end
