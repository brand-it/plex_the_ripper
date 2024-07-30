# frozen_string_literal: true

class ProgressBarComponent < ViewComponent::Base
  extend Dry::Initializer
  option :completed, Types::Coercible::Float, default: -> { 0.0 }, null: nil
  option :status, default: -> { 'info' }, null: nil
  option :message, optional: true
  option :show_percentage, default: -> { true }
  option :eta, optional: true
end
