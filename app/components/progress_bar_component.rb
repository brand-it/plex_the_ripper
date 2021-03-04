# frozen_string_literal: true

class ProgressBarComponent < ViewComponent::Base
  extend Dry::Initializer
  option :model
  option :completed, Types::Integer, default: -> { 0 }
  option :status, default: -> { 'info' }
  option :message, optional: true

  def dom_id
    "#{model.model_name.name}-progress-bar"
  end
end
