# frozen_string_literal: true

class ProgressMessageComponent < ViewComponent::Base
  extend Dry::Initializer
  option :model
  option :message, Types::Coercible::String, optional: true

  def dom_id
    "#{model.model_name.name}-progress-message"
  end
end
