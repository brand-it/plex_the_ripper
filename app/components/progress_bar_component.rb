# frozen_string_literal: true

class ProgressBarComponent < ViewComponent::Base
  extend Dry::Initializer
  option :model
  option :completed, Types::Coercible::Float, default: -> { 0.0 }, null: nil
  option :status, default: -> { 'info' }, null: nil
  option :message, optional: true

  def dom_id
    "#{model.model_name.name}-progress-bar"
  end
end
