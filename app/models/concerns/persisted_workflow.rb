# frozen_string_literal: true

module PersistedWorkflow
  extend ActiveSupport::Concern
  included do
    include Workflow

    def load_workflow_state
      self[:workflow_state]
    end

    def persist_workflow_state(new_value)
      update!(workflow_state: new_value)
    end
  end
end
